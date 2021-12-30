variable "vpc_id" {
  description = "ID of the VPC to run the masternode into"
  type        = string
}

variable "name" {
  description = "Name to be assigned to the ASG and its resources"
  type        = string
}

variable "description" {
  description = "Description to use for the Launch Template"
  type        = string
  default     = null
}

variable "subnets" {
  description = "Subnets the ASG should operate in"
  type        = list(string)
}

variable "instance_type" {
  description = "Instance type to use"
  type        = string
}

variable "blockchain_volume_size" {
  description = "Size in GB of the blockchain volume to use"
  type        = number
}

variable "blockchain_volume_snapshot" {
  description = "Snapshot to use for the blockchain volume"
  type        = string
}