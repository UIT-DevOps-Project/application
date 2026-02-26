output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_id_1" {
  value = module.networking.public_subnet_id_1
}

output "public_subnet_id_2" {
  value = module.networking.public_subnet_id_2
}


output "private_subnet_id" {
  value = module.networking.private_subnet_id
}

output "alb_dns" {
  value = module.networking.alb_dns_name
}