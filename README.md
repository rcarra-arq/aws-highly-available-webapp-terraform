![AWS](https://img.shields.io/badge/AWS-Cloud-orange)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)
![FinOps](https://img.shields.io/badge/FinOps-Cost_Governance-2ea44f)
![Reliability](https://img.shields.io/badge/Reliability-Multi--AZ_HA-1f6feb)
![Docker](https://img.shields.io/badge/Docker-Container-blue)
![Linux](https://img.shields.io/badge/Linux-Ubuntu-black)

# AWS Highly Available Web Application (Terraform)

**🇺🇸 English** · [🇧🇷 Português](#português)

> **Portfolio focus:** this repo doubles as a hands-on case study in
> **FinOps (cost governance)** and **Reliability Engineering**.
>
> - 💰 **Cost governance (FinOps)** — standardized `default_tags` (so Cost
>   Explorer can answer *"how much does this project cost?"*), an AWS Budget
>   with real-spend and forecast alerts, and a per-resource cost breakdown.
>   → [Cost Governance (FinOps)](#cost-governance-finops)
> - 🛡️ **Reliability** — multi-AZ Auto Scaling, ELB health checks, CloudWatch
>   alarms driving scaling, and a documented real-world troubleshooting case.
>   → [Reliability & Troubleshooting](#reliability--troubleshooting)

This project provisions a highly available web application on AWS using
Terraform Infrastructure as Code (IaC). The architecture is designed with
scalability, security, and automation in mind, following real-world cloud
engineering practices. It includes an Application Load Balancer, an Auto
Scaling Group, EC2 instances running Nginx, and a full CI pipeline using
GitHub Actions.

## Architecture

```
Internet
   ↓
Application Load Balancer
   ↓
Target Group
   ↓
Auto Scaling Group
   ↓
EC2 Instances (Nginx)
```

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

## Security

- ALB exposed to the internet on HTTP (port 80)
- EC2 instances are not directly exposed
- EC2 only accepts traffic from ALB Security Group
- SSH access used only for temporary debugging
- IAM role used instead of static credentials

## CI/CD Pipeline

The project uses GitHub Actions to validate Terraform code automatically.

**Pipeline includes:**

- Terraform format check
- Terraform initialization
- Terraform validation
- Terraform plan on pull requests
- Plan exported as artifact for review

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

## How to Deploy

```bash
terraform init       # initialize
terraform validate   # validate configuration
terraform plan       # create execution plan
terraform apply      # apply infrastructure
```

Retrieve the load balancer DNS and open it in a browser:

```bash
terraform output
# open http://<alb-dns>
```

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

## What I Learned

- Designing scalable AWS architectures
- Implementing Infrastructure as Code with Terraform
- Working with Load Balancers and Auto Scaling
- Building secure cloud network architectures
- Automating infrastructure validation with CI/CD pipelines
- Structuring production-like cloud environments

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

*Cloud engineering study and portfolio project — Infrastructure as Code and
DevOps practices, built hands-on.*

---

## Português

[🇺🇸 English ⬆](#aws-highly-available-web-application-terraform)

> **Foco deste projeto:** este repositório serve de estudo prático de
> **FinOps (governança de custos)** e **Engenharia de Confiabilidade**.
>
> - 💰 **Governança de custos (FinOps)** — `default_tags` padronizadas (para o
>   Cost Explorer responder *"quanto custa este projeto?"*), um AWS Budget com
>   alertas de gasto real e de previsão, e o custo detalhado por recurso.
>   → [Governança de Custos (FinOps)](#governança-de-custos-finops)
> - 🛡️ **Confiabilidade** — Auto Scaling multi-AZ, health checks do ELB,
>   alarmes do CloudWatch guiando o scaling, e um caso real de troubleshooting
>   documentado.
>   → [Confiabilidade & Troubleshooting](#confiabilidade--troubleshooting)

Este projeto provisiona uma aplicação web de alta disponibilidade na AWS
usando Terraform como Infrastructure as Code (IaC). A arquitetura foi pensada
com foco em escalabilidade, segurança e automação, seguindo práticas reais de
engenharia de nuvem. Inclui um Application Load Balancer, um Auto Scaling
Group, instâncias EC2 rodando Nginx e um pipeline de CI completo com GitHub
Actions.

### Arquitetura

```
Internet
   ↓
Application Load Balancer
   ↓
Target Group
   ↓
Auto Scaling Group
   ↓
Instâncias EC2 (Nginx)
```

### Componentes AWS

- [x] Virtual Private Cloud (VPC)
- [x] Subnets públicas (multi-AZ com for_each)
- [x] Internet Gateway
- [x] Route Tables
- [x] Application Load Balancer (ALB)
- [x] Target Group com health checks
- [x] Auto Scaling Group (ASG)
- [x] Instâncias EC2 rodando Nginx
- [x] Security Groups (arquitetura em camadas)
- [x] IAM Role com acesso SSM

### Segurança

- ALB exposto à internet via HTTP (porta 80)
- Instâncias EC2 não ficam expostas diretamente
- EC2 só aceita tráfego vindo do Security Group do ALB
- Acesso SSH usado apenas para debug temporário
- IAM role no lugar de credenciais estáticas

### Pipeline CI/CD

O projeto usa GitHub Actions para validar o código Terraform automaticamente.

**O pipeline inclui:**

- Checagem de formatação do Terraform
- Inicialização do Terraform
- Validação do Terraform
- `terraform plan` nos pull requests
- Plan exportado como artifact para revisão

### Estrutura do projeto

```
.
├── terraform/
│   ├── network.tf        # VPC, subnets (multi-AZ), IGW, roteamento
│   ├── security.tf       # security groups em camadas (ALB -> EC2)
│   ├── alb.tf            # load balancer, target group, health check
│   ├── autoscaling.tf    # ASG com health checks do ELB
│   ├── scaling.tf        # políticas de scaling + alarmes CloudWatch
│   ├── compute.tf        # busca de AMI, launch template
│   ├── cloudwatch.tf     # log groups (retenção de 7 dias)
│   ├── dashboard.tf      # dashboard CloudWatch (CPU, requisições)
│   ├── budget.tf         # AWS Budget com alertas de custo
│   ├── provider.tf       # provider + default_tags
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── userdata.sh       # nginx + /health + agente CloudWatch
└── .github/workflows/terraform-plan.yml
```

### Como fazer o deploy

```bash
terraform init       # inicializa
terraform validate   # valida a configuração
terraform plan       # cria o plano de execução
terraform apply      # aplica a infraestrutura
```

Pegue o DNS do load balancer e abra no navegador:

```bash
terraform output
# abra http://<alb-dns>
```

### Confiabilidade & Troubleshooting

**Confiabilidade por design.** A disponibilidade aqui não é sorte de um único
servidor saudável — ela é projetada: as instâncias rodam em **várias
Availability Zones**, o **health check do ELB** tira de rotação uma instância
com problema, o **Auto Scaling Group** a substitui, e **alarmes do CloudWatch**
na CPU guiam as políticas de scaling. Se uma AZ ou instância cai, o ALB
continua servindo pelas outras.

**Um caso real de troubleshooting (documentado).** Depois de HORAS de debug,
aqui está o que quebrou e como foi resolvido:
Ao montar o pipeline de CI deste projeto, o `terraform init` começou a falhar no GitHub Actions com o erro `openpgp: key expired` durante a instalação do provider da AWS. Depois de descartar má configuração do cache de plugins e de fixar o provider numa versão mais antiga (que também não resolveu), a pesquisa revelou que era um bug conhecido na verificação de assinatura do Terraform 1.6.0, corrigido em versões posteriores. Atualizar o pipeline para o Terraform 1.9.8 resolveu de vez — um bom lembrete de que falha no CI nem sempre é culpa da sua própria configuração.

### O que eu aprendi

- Projetar arquiteturas escaláveis na AWS
- Implementar Infrastructure as Code com Terraform
- Trabalhar com Load Balancers e Auto Scaling
- Construir arquiteturas de rede seguras na nuvem
- Automatizar a validação da infraestrutura com pipelines de CI/CD
- Estruturar ambientes de nuvem parecidos com produção

### Governança de Custos (FinOps)

Esta arquitetura foi pensada para ser **efêmera e barata de rodar**: sobe,
testa, destrói. O Terraform transforma o ciclo de vida completo numa questão
de dois comandos, então uma sessão de laboratório inteira custa centavos.

#### Custo estimado (us-east-1, on-demand)

| Recurso | Por hora | Por mês (se ficar ligado) |
|---|---|---|
| Application Load Balancer | ~US$0,023 | ~US$16,40 |
| 2x EC2 t3.micro | ~US$0,021 | ~US$15,20 |
| 2x EBS gp3 8 GB | ~US$0,002 | ~US$1,30 |
| CloudWatch (3 log groups, 2 alarmes, 1 dashboard) | ~US$0,00 | dentro do free tier nessa escala |
| **Total** | **~US$0,05/hora** | **~US$33/mês** |

Uma sessão típica de 4 horas: **~US$0,20**. O verdadeiro risco de custo não é
o uso — é *esquecer a stack ligada*. Os controles abaixo existem para isso.

#### Controles de custo neste projeto

- **Tagging padronizado** — todo recurso carrega as tags `Project`,
  `Environment` e `ManagedBy` via `default_tags` do provider, explicitamente
  mescladas no launch template para as instâncias criadas pelo ASG (que não
  herdam as tags do provider). É isso que permite o Cost Explorer responder
  *"quanto custa este projeto?"* em vez de *"quanto custa minha conta?"*.
- **AWS Budget com alertas por e-mail** (`budget.tf`) — orçamento mensal da
  conta inteira (padrão US$10) alertando em 80% do gasto real e em 100% do
  gasto *previsto*. Budgets de custo simples são gratuitos. Defina seu e-mail
  num `terraform.tfvars` que fica no gitignore:
  ```hcl
  alert_email = "voce@exemplo.com"
  ```
- **Padrões conscientes de custo** — retenção de logs do CloudWatch limitada a
  7 dias (retenção infinita é cobrada para sempre), `t3.micro` no lugar do
  `t2.micro` mais antigo e um pouco mais caro, e ASG limitado a `max_size = 2`.

#### Padrão de uso

```bash
terraform apply   # constrói tudo (~3 min)
# ...testa, quebra coisas, aprende...
terraform destroy # derruba tudo - US$0 enquanto destruído
```

### Melhorias futuras

- HTTPS com ACM e Route 53
- Deploys Blue/Green
- Backend remoto com S3 e DynamoDB
- Subnets privadas para a camada EC2
- WAF na frente do ALB
- `terraform plan` autenticado via OIDC no CI (bloqueado no sandbox da Academy)

Já entregues desta lista: monitoramento com CloudWatch (log groups, dashboard
e alarmes de CPU guiando as políticas de Auto Scaling) e controles de custo
(tagging, alertas de budget, estimativas de custo).

*Projeto de estudo e portfólio em engenharia de nuvem — Infrastructure as Code
e práticas de DevOps, construído na prática.*
