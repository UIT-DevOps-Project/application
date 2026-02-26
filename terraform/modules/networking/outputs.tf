output "vpc_id" {
  value       = aws_vpc.this.id
}

output "public_subnet_id_1" {
  value       = aws_subnet.public_1.id
}

output "public_subnet_id_2" {
  value       = aws_subnet.public_2.id
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
}

output "igw_id" {
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.nat.id
}

output "nat_eip" {
  value       = aws_eip.nat.public_ip
}

output "alb_sg_id" {
  value       = aws_security_group.alb.id
}

output "eks_node_sg_id" {
  value       = aws_security_group.eks_node.id
}

output "eks_cluster_sg_id" {
  value       = aws_security_group.eks_cluster.id
}

output "alb_arn" {
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  value       = aws_lb_target_group.this.arn
}

