resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability #cho phép ghi đè tag của image đã tồn tại trong repository

  image_scanning_configuration {
    scan_on_push = true #tự động quét lỗ hổng bảo mật khi push image mới vào repository
  } 

  tags = {
    Name        = var.repository_name
    Environment = "dev"
  }
}