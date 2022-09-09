variable "region" {
  description = "Region to build the infrastructure into"
  type        = string
  default     = "us-east-1"
}

variable "azs" {
  description = "Availability Zones services should be redundant into"
  type        = list(string)
  default     = ["a", "b", "c"]
}