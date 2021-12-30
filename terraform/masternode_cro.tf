# module "masternode_cro" {
#   source = "../modules/masternode"

#   vpc_id                      = module.vpc_main.id
#   name                        = "cro"
#   description                 = "CRO Masternode"
#   subnets                     = module.vpc_main.public_subnets
#   instance_type               = "t2.micro"
#   blockchain_volume_size      = 4
#   blockchain_volume_snapshot  = "snap-0be0513e93e4fcdb7"
# }