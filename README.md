Terraform Infrastructure Deployment on AWS

[![Terraform](https://img.shields.io/badge/Terraform-v1.8-blue.svg)]()
[![AWS](https://img.shields.io/badge/AWS-Cloud-orange.svg)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)]()

> **End‑to‑end Infrastructure‑as‑Code blueprint** that provisions a secure, production‑ready AWS stack: custom VPC, segmented subnets, NAT & Internet gateways, EC2 Node.js web server, RDS MySQL database, S3/CloudFront for assets, and centralized remote state.

---

## Table of Contents

1. [Features](#1-features)
2. [Architecture](#2-architecture)
3. [Quick Start](#3-quick-start)
4. [Project Layout](#4-project-layout)
5. [Inputs & Outputs](#5-inputs--outputs)
6. [Security Hardening](#6-security-hardening)
7. [Operations](#7-operations)
8. [Cost & FinOps](#8-cost--finops)
9. [Contributing](#9-contributing)
10. [License](#10-license)

---

## 1. Features

* ☁ **Complete networking layer** — one click creates VPC, public/private subnets across 2 AZs, route tables, IGW, NAT GW.
 **Least‑privilege security groups** locking traffic to required ports only.
 **Compute tier** — Amazon Linux 2 EC2 instance, user‑data bootstrap installs Node.js & PM2, pulls code from Git.
 **Data tier** — Multi‑AZ RDS MySQL 5.7 in private subnet with encrypted storage.
 **Remote state** — S3 backend with DynamoDB locking for safe team collaboration.
 **CI/CD ready** — includes GitHub Actions workflow for automated `terraform fmt`, `validate`, and plan feedback.
 **Secure by default** — no hard‑coded secrets, all sensitive values injected via `.tfvars` or SSM.
 **Idempotent & modular** — each component is a reusable Terraform module.

---

## 2. Architecture

```
            ┌──────────────────────── AWS ────────────────────────┐
            │                         VPC                         │
            │                                                    │
Public Subnet        Private Subnet                   Private Subnet
(AZ‑A)               (AZ‑A)                          (AZ‑B)
┌──────────────┐     ┌──────────────┐                ┌──────────────┐
│  EC2 Web     │──SG─│  RDS MySQL   │<───multi‑AZ────│  RDS MySQL   │
│  Node.js     │     └──────────────┘                └──────────────┘
└──────────────┘
│
│  (HTTP/HTTPS) via ALB
└──────────────────────────────────────── Internet ───┘
```

*A full PNG diagram is available in* `docs/architecture.png`.

---

## 3. Quick Start

```bash
# 1. Clone repository
$ git clone https://github.com/your‑handle/terraform‑aws‑full‑stack‑iac.git
$ cd terraform‑aws‑full‑stack‑iac

# 2. Configure AWS credentials (env vars or ~/.aws/credentials)

# 3. Customize variables
$ cp example.tfvars terraform.tfvars
$ vim terraform.tfvars   # set region, key name, DB password …

# 4. Init & deploy
$ terraform init
$ terraform plan -var-file="terraform.tfvars"
$ terraform apply -var-file="terraform.tfvars"
```

### Teardown

```bash
terraform destroy -var-file="terraform.tfvars"
```

---

## 4. Project Layout

```
.
├── modules/
│   ├── network/          # VPC, subnets, IGW, NAT GW
│   ├── compute/          # EC2 + user‑data
│   ├── database/         # RDS MySQL
│   └── s3_remote_state/  # backend bucket & DynamoDB lock
├── envs/
│   ├── dev/
│   └── prod/
├── .github/workflows/
│   └── terraform.yml
├── docs/
│   ├── architecture.png
│   └── change-log.md
└── main.tf
```

---

## 5. Inputs & Outputs

Run the following command to generate a table of variables and outputs:

```bash
terraform-docs markdown table .
```

Key outputs include:

* `web_public_dns` – Public DNS of the Application Load Balancer.
* `db_endpoint` – Writer endpoint of the RDS instance.

---

## 6. Security Hardening

| Control            | Implementation                                           |
| ------------------ | -------------------------------------------------------- |
| **TLS Everywhere** | ACM certificate + ALB HTTPS listeners                    |
| **Key Management** | 4096‑bit RSA key pair generated locally via `ssh-keygen` |
| **IAM**            | Terraform least‑privilege role; no inline credentials    |
| **Data‑at‑rest**   | EBS & RDS encryption enabled                             |
| **Secrets**        | Stored in AWS Secrets Manager or SSM Parameter Store     |

---

## 7. Operations

* **Rolling updates** — modify AMI ID to trigger replacement while keeping downtime minimal.
* **Backups** — RDS automated backups (7 days) plus manual snapshots via `aws backup`.
* **Monitoring** — CloudWatch metrics and alarms defined in `monitoring.tf` with email/SNS notifications.

---

## 8. Cost & FinOps

Use [Infracost](https://www.infracost.io/) to estimate monthly spend:

```bash
infracost breakdown --path . --terraform-var-file terraform.tfvars
```

---

## 9. Contributing

1. **Fork** the repo and create your branch: `git checkout -b feature/my-feature`.
2. **Commit** your changes: `git commit -m 'feat: add new feature'`.
3. **Push** to the branch: `git push origin feature/my-feature`.
4. **Open Pull Request** and describe your changes.

Please run `terraform fmt` and `terraform validate` before submitting.

---

## 10. License

Distributed under the **MIT License**. See `LICENSE` for more information.
