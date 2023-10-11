variable "policy" {
    type = object ({
        name     = string
        filename = string
        })
}

variable "role" {
    type = object ({
        name   = string
        })
}