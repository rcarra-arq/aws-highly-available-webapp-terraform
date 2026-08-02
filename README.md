![AWS](https://img.shields.io/badge/AWS-Cloud-orange)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)
![FinOps](https://img.shields.io/badge/FinOps-Cost_Governance-2ea44f)
![Reliability](https://img.shields.io/badge/Reliability-Multi--AZ_HA-1f6feb)
![Docker](https://img.shields.io/badge/Docker-Container-blue)
![Linux](https://img.shields.io/badge/Linux-Ubuntu-black)

## *AWS Highly Available Web Application (Terraform)*
---

> **Portfolio focus / Foco deste projeto:** this repo doubles as a hands-on
> case study in **FinOps (cost governance)** and **Reliability Engineering**.
>
> - **Cost governance (FinOps)** — standardized `default_tags` (so Cost
>   Explorer can answer *"how much does *this project* cost?"*), an AWS Budget
>   with real-spend and forecast alerts, and a per-resource cost breakdown.
>   → [Cost Governance (FinOps)](#cost-governance-finops)
> - **Reliability** — multi-AZ Auto Scaling, ELB health checks, CloudWatch
>   alarms driving scaling, and a documented real-world troubleshooting case.
>   → [Reliability &amp; Troubleshooting](#reliability--troubleshooting)
>
> *Este projeto também serve de estudo prático de **FinOps** (tagging
> padronizado + AWS Budgets com alertas reais) e **Engenharia de
> Confiabilidade** (multi-AZ, health checks, alarmes) — com um caso de
> troubleshooting real documentado.*

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

```
.
├── terraform/
│   ├── network.tf        # VPC, subnets (multi-AZ), IGW, routing
│   ├── security.tf       # layered security groups (ALB -> EC2)
│   ├── alb.tf            # load balancer, target group, health check
│   ├── autoscaling.tf    # ASG with ELB health checks
│   ├── scaling.tf        # scaling policies + CloudWatch alarms
│   ├── compute.tf        # AMI lookup, launch template
│   ├── cloudwatch.tf     # log groups (7-day retention)
│   ├── dashboard.tf      # CloudWatch dashboard (CPU, requests)
│   ├── budget.tf         # AWS Budget with cost alerts
│   ├── provider.tf       # provider + default_tags
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── userdata.sh       # nginx + /health + CloudWatch agent
└── .github/workflows/terraform-plan.yml
```

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

## Reliability & Troubleshooting

**Reliability by design.** Availability here is not an accident of a single
healthy server — it is engineered: instances run across **multiple
Availability Zones**, the **ELB health check** pulls an unhealthy instance out
of rotation, the **Auto Scaling Group** replaces it, and **CloudWatch alarms**
on CPU drive the scaling policies. If one AZ or instance fails, the ALB keeps
serving from the others.

**A real troubleshooting case (documented).** After HOURS of debugging, here is
what broke and how it was fixed:
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

## Cost Governance (FinOps)

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
- Remote backend with S3 and DynamoDB
- Private subnets for EC2 layer
- WAF in front of ALB
- OIDC-authenticated `terraform plan` in CI (blocked in the Academy sandbox)

Already delivered from this list: CloudWatch monitoring (log groups, dashboard
and CPU alarms driving the Auto Scaling policies) and cost controls (tagging,
budget alerts, cost estimates).

---

Cloud engineering project developed as part of AWS learning journey focused on Infrastructure as Code and DevOps practices.

This project implements a highly available AWS architecture using Terraform, including an Application Load Balancer, Auto Scaling Group, and EC2 instances across multiple Availability Zones. It follows cloud best practices such as infrastructure as code, security segmentation, and CI/CD automation using GitHub Actions.

---
