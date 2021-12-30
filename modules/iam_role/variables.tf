variable "name_prefix" {
  description = "Prefix to be applied to the role and underlying resources"
  type        = string
  default     = ""
}

variable "name" {
  description = "Name of the role"
  type        = string
}

variable "path" {
  description = "Role path"
  type        = string
  default     = "/"
}

variable "attachments_arn" {
  description = "List of attachments ARN to the role with existing roles"
  type        = list(string)
  default     = []
}

variable "policies" {
  description = "List of inline custom policies to assign to the role"
  type        = list(object({
    name      = string
    policy    = string
  }))
}

variable "assume_role_policy" {
  description = "Assume policy to be used for the role"
  type        = string
}