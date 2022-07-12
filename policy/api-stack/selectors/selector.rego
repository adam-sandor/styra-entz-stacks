package stacks.SYSTEM_ID.selectors

import data.library.v1.utils.labels.match.v1 as match

systems[system_id] {
  include := {
    "system-type": {
        "entitlements"
    },
    "designation": {
        "regional-api"
    }
  }

  exclude := {}

  metadata := data.metadata[system_id]
  match.all(metadata.labels.labels, include, exclude)
}
