module "masternode_cro" {
  source = "../modules/masternode"

  region                     = var.region
  vpc_id                     = module.vpc_main.id
  name                       = "cro"
  description                = "CRO Masternode"
  subnets                    = module.vpc_main.public_subnets
  instance_type              = "t2.micro"
  blockchain_volume_size     = 8
  blockchain_volume_snapshot = "snap-08391e1d0fe151035"
}