module "vpc_main" {
  source = "../modules/vpc"

  region  = var.region
  azs     = formatlist("${var.region}%s", var.azs)

  name          = "main"
  cidr          = "192.168.0.0/16"
  subnets_cidr  = [
    {
      public  = "192.168.0.0/23"
      private = "192.168.2.0/23"
    },
    {
      public  = "192.168.20.0/23"
      private = "192.168.22.0/23"
    },
    {
      public  = "192.168.40.0/23"
      private = "192.168.42.0/23"
    }
  ]
}