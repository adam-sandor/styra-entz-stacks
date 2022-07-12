set -e
source .env

function put_policy {
local POLICY_FILE=$1
local SYSTEM_ID=$2
local POLICY_PATH=$3

local FILE=$(sed 's/$/\\n/' "$POLICY_FILE" | tr -d '\n' | sed 's/"/\\"/g' | sed "s/SYSTEM_ID/$SYSTEM_ID/g")
local POLICY_PUT=$(cat << EOF
{
  "language": "rego",
  "modules": {
    "$(basename $POLICY_FILE)": "$FILE"
  }
}
EOF
)

curl -H "Authorization: Bearer ${API_TOKEN}" -H "Content-Type: application/json" -X PUT \
  "$DAS_TENANT/v1/policies/$POLICY_PATH" -d "$POLICY_PUT"
}

function setup_system {
local SYSTEM_NAME=$1
SYSTEM_DEF=$(curl --request POST \
  --url $DAS_TENANT/v1/systems \
  --header 'authorization: Bearer '$API_TOKEN'' \
  --header 'content-type: application/json' \
  --data \
  '{
    "name": "'$SYSTEM_NAME'",
    "read_only": false,
    "type": "template.entitlements:1.0"
  }')

local SYSTEM_ID=$(echo $SYSTEM_DEF | jq -r '.result.id')

echo "System created with ID $SYSTEM_ID"

put_policy "policy/$SYSTEM_NAME-system/policy/rules.rego" $SYSTEM_ID "systems/$SYSTEM_ID/policy"
put_policy "policy/metadata/labels.rego" $SYSTEM_ID "metadata/$SYSTEM_ID/labels"

curl -H "Authorization: Bearer ${API_TOKEN}" -H "Content-Type: application/json" \
     -X PUT "$DAS_TENANT/v1/datasources/systems/$SYSTEM_ID/managers" -d '
{
    "category": "rest",
    "type": "push"
}'

curl -H "Authorization: Bearer ${API_TOKEN}" -H "Content-Type: application/json" \
     -X PUT "$DAS_TENANT/v1/data/systems/$SYSTEM_ID/managers" -d "@data/managers-$SYSTEM_NAME.json"

}

setup_system "api-region1"
setup_system "api-region2"

STACK_DEF=$(curl --request POST \
  --url $DAS_TENANT/v1/stacks \
  --header 'authorization: Bearer '$API_TOKEN'' \
  --header 'content-type: application/json' \
  --data \
  '{
    "name": "api-master-policies",
    "read_only": false,
    "type": "template.entitlements:1.0"
  }')

STACK_ID=$(echo $STACK_DEF | jq -r '.result.id')

echo "Stack created with ID $STACK_ID"

put_policy "policy/api-stack/policy/rules.rego" $STACK_ID "stacks/$STACK_ID/policy"
put_policy "policy/api-stack/selectors/selector.rego" $STACK_ID "stacks/$STACK_ID/selectors"