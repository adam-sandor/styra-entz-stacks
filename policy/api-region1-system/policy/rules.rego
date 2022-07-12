package policy
import future.keywords.in

enforce[decision] {
    #title: Admin can do anything
    input.subject == "region1-admin@acme.org"
    decision := {
        "allowed": true,
        "message": "region1-admin@acme.org can do anything"
    }
}