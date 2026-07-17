![AWS](https://img.shields.io/badge/AWS-Cloud-orange)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)
![Docker](https://img.shields.io/badge/Docker-Container-blue)
![Linux](https://img.shields.io/badge/Linux-Ubuntu-black)

## *AWS Highly Available Web Application (Terraform)*
---

Overview (English)

This project provisions a highly available web application on AWS using Terraform Infrastructure as Code (IaC). The architecture is designed with scalability, security, and automation in mind, following real-world cloud engineering practices. It includes an Application Load Balancer, Auto Scaling Group, EC2 instances running Nginx, and a full CI pipeline using GitHub Actions.

Visão Geral (Português)

Este projeto implementa uma aplicação altamente disponível na AWS utilizando Terraform como Infrastructure as Code (IaC). A arquitetura foi projetada com foco em escalabilidade, segurança e automação, seguindo boas práticas de engenharia de cloud. Inclui Load Balancer, Auto Scaling Group, instâncias EC2 com Nginx e pipeline de CI com GitHub Actions.

---

## Architecture | Arquitetura

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

## AWS Components

- [x] Virtual Private Cloud (VPC)
- [x] Public Subnets (Multi-AZ using for_each)
- [x] Internet Gateway
- [x] Route Tables
- [x] Application Load Balancer (ALB)
- [x] Target Group with Health Checks
- [x] Auto Scaling Group (ASG)
- [x] EC2 Instances running Nginx
- [x] Security Groups (layered architecture)
- [x] IAM Role with SSM access
  
---

## Security 

- ALB exposed to the internet on HTTP (port 80)
- EC2 instances are not directly exposed
- EC2 only accepts traffic from ALB Security Group
- SSH access used only for temporary debugging
- IAM role used instead of static credentials
  
---

## CI/CD Pipeline

The project uses GitHub Actions to validate Terraform code automatically.

## Pipeline includes:
- Terraform format check
- Terraform initialization
- Terraform validation
- Terraform plan on pull requests
- Plan exported as artifact for review
---
## Project Structure

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
## How to Deploy

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

## Challenges & Troubleshooting

And worth mentioning after HOURS of trying to debug what was going on, finally found out what was going on and fixed it:
While setting up the CI pipeline for this project, `terraform init` began failing in GitHub Actions with an `openpgp: key expired` error during AWS provider installation. After ruling out plugin cache misconfiguration and pinning the provider to an older version (which didn't resolve it either), research revealed this was a known bug in Terraform 1.6.0's signature verification, fixed in later releases. Updating the pipeline to Terraform 1.9.8 resolved it completely — a good reminder that CI failures aren't always caused by your own configuration.

---

## What I Learned

- Designing scalable AWS architectures
- Implementing Infrastructure as Code with Terraform
- Working with Load Balancers and Auto Scaling
- Building secure cloud network architectures
- Automating infrastructure validation with CI/CD pipelines
- Structuring production-like cloud environments
  
---

## Cost Optimization

This architecture is designed to be **ephemeral and cheap to run**: spin it up,
test it, destroy it. Terraform makes the full lifecycle a two-command affair,
so a complete lab session costs cents.

### Estimated cost (us-east-1, on-demand)

| Resource | Hourly | Monthly (if left running) |
|---|---|---|
| Application Load Balancer | ~$0.023 | ~$16.40 |
| 2x EC2 t3.micro | ~$0.021 | ~$15.20 |
| 2x EBS gp3 8 GB | ~$0.002 | ~$1.30 |
| CloudWatch (3 log groups, 2 alarms, 1 dashboard) | ~$0.00 | within free tier at this scale |
| **Total** | **~$0.05/hour** | **~$33/month** |

A typical 4-hour lab session: **~$0.20**. The real cost risk is not usage —
it is *forgetting the stack running*. The controls below exist for that.

### Cost controls in this project

- **Standardized tagging** — every resource carries `Project`, `Environment`
  and `ManagedBy` tags via the provider's `default_tags`, explicitly merged
  into the launch template for ASG-launched instances (which do not inherit
  provider tags). This is what lets Cost Explorer answer *"how much does this
  project cost?"* instead of *"how much does my account cost?"*.
- **AWS Budget with email alerts** (`budget.tf`) — account-wide monthly budget
  (default $10) alerting at 80% of actual spend and at 100% of *forecasted*
  spend. Plain cost budgets are free. Set your email in a gitignored
  `terraform.tfvars`:
  ```hcl
  alert_email = "you@example.com"
  ```
- **Cost-conscious defaults** — CloudWatch log retention capped at 7 days
  (unbounded retention is billed forever), `t3.micro` over the older and
  slightly pricier `t2.micro`, ASG capped at `max_size = 2`.

### Usage pattern

```bash
terraform apply   # build everything (~3 min)
# ...test, break things, learn...
terraform destroy # tear everything down - $0 while destroyed
```

---

## Future Improvements

- HTTPS with ACM and Route 53
- Blue/Green deployments
- CloudWatch monitoring and alarms
- Remote backend with S3 and DynamoDB
- Private subnets for EC2 layer
- WAF in front of ALB

---

Cloud engineering project developed as part of AWS learning journey focused on Infrastructure as Code and DevOps practices.

This project implements a highly available AWS architecture using Terraform, including an Application Load Balancer, Auto Scaling Group, and EC2 instances across multiple Availability Zones. It follows cloud best practices such as infrastructure as code, security segmentation, and CI/CD automation using GitHub Actions.

---
