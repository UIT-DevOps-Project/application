#--------------VPC----------------------
#tạo vpc với CIDR block
resource "aws_vpc" "this"{
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "devops-vpc"
    }
}

#------------Subnets-------------------
#tạo subnet public và private trong vpc đã tạo
resource "aws_subnet" "public_1" {
    vpc_id = aws_vpc.this.id
    cidr_block = var.public_subnet_cidr_1
    availability_zone = "ap-southeast-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "devops-public-subnet-1"
    }
}

resource "aws_subnet" "public_2" {
    vpc_id = aws_vpc.this.id
    cidr_block = var.public_subnet_cidr_2
    availability_zone = "ap-southeast-1b"  
    map_public_ip_on_launch = true

    tags = {
        Name = "devops-public-subnet-2"
    }
}
resource "aws_subnet" "private" {
    vpc_id = aws_vpc.this.id
    cidr_block = var.private_subnet_cidr
    availability_zone = "ap-southeast-1a"

    tags = {
        Name = "devops-private-subnet"
    }
}

#---------------IGW - Internet Gateway-----------------
#tạo internet gateway và attach vào vpc để kết nối vpc với internet
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.this.id
}

#----------------Public Route Table---------------------
#tạo route table cho subnet public và thêm route để kết nối với internet qua internet gateway
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "public_assoc_1" {
    subnet_id = aws_subnet.public_1.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_assoc_2" {
    subnet_id = aws_subnet.public_2.id
    route_table_id = aws_route_table.public.id
}

#----------------NAT Gateway---------------------
#tạo elastic IP cho NAT gateway và tạo NAT gateway trong subnet public để cho phép subnet private truy cập internet
resource "aws_eip" "nat" {
    domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public_1.id
}
#----------------Private Route Table---------------------
#tạo route table cho subnet private và thêm route để kết nối với internet qua NAT gateway
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }
}
resource "aws_route_table_association" "private_assoc" {
    subnet_id = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}

#----------------Security Group---------------------
#tạo security group cho ALB với rule cho phép truy cập từ internet qua port 80 và 443 để ALB có thể nhận traffic từ người dùng
resource "aws_security_group" "alb" {
    name = "devops-alb-sg"
    vpc_id = aws_vpc.this.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
#tạo security group cho EKS node với rule cho phép truy cập từ ALB qua tất cả các port để kết nối giữa ALB và EKS node
resource "aws_security_group" "eks_node" {
    name = "devops-eks-node-sg"
    vpc_id = aws_vpc.this.id

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = [aws_security_group.alb.id]
    }
    ingress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        self      = true
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
#tạo security group cho EKS cluster với rule cho phép truy cập từ team IP qua port 443 để quản lý cluster
resource "aws_security_group" "eks_cluster" {
  name   = "devops-eks-cluster-sg"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow all - IAM will handle auth
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#----------------------ALB--------------------------
#tạo application load balancer trong subnet public với security group đã tạo để ALB có thể nhận traffic từ người dùng và kết nối với EKS node
resource "aws_lb" "this" {
    name = "devops-alb"
    load_balancer_type = "application"
    internal = false
    subnets = [
        aws_subnet.public_1.id,
        aws_subnet.public_2.id
    ]
    security_groups = [aws_security_group.alb.id]   
}
#tạo target group cho ALB để kết nối với EKS node qua port 80
resource "aws_lb_target_group" "this" {
    name = "devops-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.this.id
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.this.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.this.arn
    }
}

