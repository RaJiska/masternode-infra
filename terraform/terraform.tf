provider "aws" {
  profile	= "masternode"
  region	= "us-east-1"
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.70.0"
    }
  }
}