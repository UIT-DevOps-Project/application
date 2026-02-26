# infrastructure
## Project Overview
Hiện tại đã triển khai:
    -VPC
    -Public & Private Subnet
    -Internet Gateway
    -NAT Gateway
    -Route Tables
    -Security Groups
    -Application Load Balancer (ALB)
    -Amazon ECR Repository
## Những gì đã tạo
### 1. VPC 
    - name: devops-vpc
    - CIDR: 10.0.0.0/16
    - DNS: enabled
### 2. Subnets
    2 Public Subnets + 1 Private Subnet
    Public Subnet 1:
    - CIDR: 10.0.1.0/24
    - AZ: ap-southeast-1a
    - Auto assign public IP: enabled

    Public Subnet 2:
    - CIDR: 10.0.3.0/24
    - AZ: ap-southeast-1b
    - Auto assign public IP: enabled

    Private Subnet:
    - CIDR: 10.0.2.0/24
    - AZ: ap-southeast-1a
    - No public IP
### 3. Internet Gateway
    - Attached vào VPC
    - Public subnet route:
    0.0.0.0/0 -> IGW
### 4. NAT Gateway
    - Đặt trong Public Subnet
    - Có Elastic IP
    - Private subnet route:
    0.0.0.0/0 -> NAT
### 5. Security Groups
    ALB SG:
    - Inbound 80,443 từ Internet
    - Outbound all
    EKS Node SG:
    - Inbound từ ALB SG
    - Inbound self
    - Outbound all
    EKS Cluster SG
    - Inbound 443 từ Internet
    - Xác thực bằng IAM
### 6. Application load Balancer
    - Type: Application
    - Scheme: Internet-facing
    - Subnet: Public
    - Listener: 80
    - Target Group: IP Type
### 7. ECR Reponsitory
    - Name: devops-ecr
    - Scan on push: enabled
    - Mutable

## Outputs sau khi terraform apply trả về:
- vpc_id
- public_subnet_id_1
- public_subnet_id_2
- private_subnet_id
- alb_dns
- ecr_repository_url

## Cách chạy project
### Bước 1: Cấu hình aws
- Add key và secret key từ IAM
```bash
aws configure
```
-Sau khi add kiểm tra bằng lệnh
```bash
aws sts get-caller-identity
```
### Bước 2: Initialize Terraform
```bash
terraform init
terraform plan
```
### Bước 3: Apply
```bash
terraform apply
```
### Nếu muốn gỡ all thì sử dụng lệnh:
```bash
terraform destroy
```