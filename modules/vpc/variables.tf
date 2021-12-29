variable "region" {
  description = "Region to run the VPC in"
  type        = string
}

variable "azs" {
  description = "Availability Zones withing which the VPC will operate"
  type        = list(string)
}

variable "name" {
  description	= "Name of the VPC and its associated resources"
  type        = string
}

variable "cidr" {
  description = "CIDR to use for the VPC"
  type        = string
}

variable "subnets_cidr" {
  description = "CIDR to be assigned to each subnet in each Availability Zone"
  type        = list(object({
    public  = string
    private = string
  }))
}