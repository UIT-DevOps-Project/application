variable "repository_name" {
  type        = string
  default     = "devops-ecr"
}

variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE" #cho phép ghi đè tag của image đã tồn tại trong repository
}