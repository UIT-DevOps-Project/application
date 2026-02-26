module "networking" {
  source     = "./modules/networking"
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = "devops-ecr"
}