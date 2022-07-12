package stacks.SYSTEM_ID.policy

enforce[decision] {
    #title: /info is accessible to all employees
    input.resource == "/api/v1/info"
    endswith(input.subject, "@acme.org")
    decision := {
        "allowed": true,
        "message": "/info is accessible to all employees"
    }
}
enforce[decision] {
    #title: /salary/{id} accessible to managers
    split_path := split(input.resource, "/")
    split_path = ["", "api", "v1", "salary", _]
    
    is_manager(input.subject)
    
    decision := {
        "allowed": true,
        "message": "/salary accessible to managers"
    }
}

enforce[decision] {
    #title: Managers can't see other managers' salaries
    split_path := split(input.resource, "/")
    split_path = ["", "api", "v1", "salary", id]
    
    is_manager(input.subject)
    is_manager(id)
    
    decision := {
        "denied": true,
        "message": "Managers can't see other managers' salaries"
    }
}

is_manager(id) {
    data.managers[id]
}