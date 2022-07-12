# Entitlements Stacks Demo

This demo setup shows how the Entitlements system type can use Stacks to implement both central and specific policies
that authorize API access. The demo setup contains two region specific API policies and a Stack enforcing policies
over both regions. In this scenario most policies are common between the regions but each region has a different
dataset (list of managers) and some region-specific policies.

Note that this demo requires a [Styra DAS](https://www.styra.com/styra-das/) tenant. You can request one at https://signup.styra.com.

## Installation

1. Create a file called .env in the root folder. Define the following variables in it:
```shell
DAS_TENANT=<YOUR STYRA DAS URL>
API_TOKEN=<YOUR API TOKEN>
```
See [this page](https://docs.styra.com/administration/token-management/create-api-token) on how to create an API token.

2. Run `./setup-das-systems-stack.sh` to create the two systems and the stack

## Play with the demo

You can either run local OPA(s) where you deploy the demo System(s) or you can play with the sample inputs straight in
Styra DAS using the Preview functionality.

Here are some sample inputs you can try. You can paste these straight into the input box in Styra DAS or use them as the
payload in requests to OPA (see example request further down).

### Sample 1
```json
{
  "subject": "jane@styra.com",
  "resource": "/api/v1/managers",
  "action": "GET"
}
```
This will produce a policy violation as jane@styra.com isn't an acme.org employee.

### Sample 2
```json
{
  "subject": "region1-admin@acme.org",
  "resource": "/api/v1/managers",
  "action": "GET"
}
```
This request will be allowed in api-region1 but denied in api-region2 because of the special policy in api-region1 rules.rego.

### Sample 3
```json
{
  "subject": "eve@acme.org",
  "resource": "/api/v1/salary/adam@acme.org",
  "action": "GET"
}
```
This will be allowed in System api-region2 because Eve is listed as a manager there (see datasource `managers`), but will
be denied in api-region1 as the list of managers is different there. The policy itself is defined on the Stack level but
the data is region specific.

