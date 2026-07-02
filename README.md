
![AWS](https://img.shields.io/badge/AWS-Cloud-orange)

## AWS Highly Available Web Application (Terraform)
---
Overview (English)

This project provisions a highly available web application on AWS using Terraform Infrastructure as Code (IaC). The architecture is designed with scalability, security, and automation in mind, following real-world cloud engineering practices. It includes an Application Load Balancer, Auto Scaling Group, EC2 instances running Nginx, and a full CI pipeline using GitHub Actions.

Visão Geral (Português)

Este projeto implementa uma aplicação altamente disponível na AWS utilizando Terraform como Infrastructure as Code (IaC). A arquitetura foi projetada com foco em escalabilidade, segurança e automação, seguindo boas práticas de engenharia de cloud. Inclui Load Balancer, Auto Scaling Group, instâncias EC2 com Nginx e pipeline de CI com GitHub Actions.
---
Architecture | Arquitetura

Internet
↓
Application Load Balancer
↓
Target Group
↓
Auto Scaling Group
↓
EC2 Instances (Nginx)
---
AWS Components

- Virtual Private Cloud (VPC)
- Public Subnets (Multi-AZ using for_each)
- Internet Gateway
- Route Tables
- Application Load Balancer (ALB)
- Target Group with Health Checks
- Auto Scaling Group (ASG)
- EC2 Instances running Nginx
- Security Groups (layered architecture)
- IAM Role with SSM access
---
Security Design

- ALB exposed to the internet on HTTP (port 80)
- EC2 instances are not directly exposed
- EC2 only accepts traffic from ALB Security Group
- SSH access used only for temporary debugging
- IAM role used instead of static credentials
---
CI/CD Pipeline

The project uses GitHub Actions to validate Terraform code automatically.

Pipeline includes:
- Terraform format check
- Terraform initialization
- Terraform validation
- Terraform plan on pull requests
- Plan exported as artifact for review
---
Project Structure

.
├── network.tf
├── security.tf
├── compute.tf
├── alb.tf
├── autoscaling.tf
├── variables.tf
├── outputs.tf
├── userdata.sh
└── .github/workflows/terraform.yml
---
How to Deploy

Initialize Terraform:
terraform init

Validate configuration:
terraform validate

Create execution plan:
terraform plan

Apply infrastructure:
terraform apply

Access Application

Retrieve Load Balancer DNS:
terraform output

Open in browser:
http://<alb-dns>
---
What I Learned

- Designing scalable AWS architectures
- Implementing Infrastructure as Code with Terraform
- Working with Load Balancers and Auto Scaling
- Building secure cloud network architectures
- Automating infrastructure validation with CI/CD pipelines
- Structuring production-like cloud environments
---
Future Improvements

- HTTPS with ACM and Route 53
- Blue/Green deployments
- CloudWatch monitoring and alarms
- Remote backend with S3 and DynamoDB
- Private subnets for EC2 layer
- WAF in front of ALB

---
Cloud engineering project developed as part of AWS learning journey focused on Infrastructure as Code and DevOps practices.

This project implements a highly available AWS architecture using Terraform, including an Application Load Balancer, Auto Scaling Group, and EC2 instances across multiple Availability Zones. It follows cloud best practices such as infrastructure as code, security segmentation, and CI/CD automation using GitHub Actions.

And worth mentioning after HOURS of trying to debug what was going on, that "openpgp: key expired" in Terraform is a known Terraform 1.6.0 bug, not a config mistake!! Finally found out what was going on and fixed it!
---
