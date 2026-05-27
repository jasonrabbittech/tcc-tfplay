# Tencent Cloud Terraform GitOps Demo

GitHub Actions + Terraform CI/CD pipeline for Tencent Cloud, organized in the style of the official [gitops-terraform](https://github.com/tencentcloudstack/gitops-terraform) reference. Two independent stacks demonstrate end-to-end GitOps:

- **`environments/default`** — VPC / Subnet / Security Group / CVM / EIP / COS resource provisioning.
- **`environments/identity`** — Identity Center (SSO) role configuration, policy attachments, and member-account role assignments.

Each stack has its own state, its own approval gate, and its own apply / destroy workflows.

---

## Table of contents

- [Repository layout](#repository-layout)
- [Workflows](#workflows)
- [One-time setup](#one-time-setup)
- [Day-to-day usage](#day-to-day-usage)
- [Default stack — what it provisions](#default-stack--what-it-provisions)
- [Identity stack — what it provisions](#identity-stack--what-it-provisions)
- [Local debugging](#local-debugging)
- [Security notes](#security-notes)
- [Cross-account reuse](#cross-account-reuse)

---

## Repository layout

```
.
├── .github/
│   └── workflows/
│       ├── terraform-pr-check.yml      # PR check: fmt + init + validate + plan, comments on PR
│       ├── terraform-apply.yml         # Push to main: apply default stack (production approval)
│       ├── terraform-destroy.yml       # Manual: destroy default stack (typed confirmation + approval)
│       ├── identity-apply.yml          # Push to main: apply identity stack (identity-production approval)
│       └── identity-destroy.yml        # Manual: destroy identity stack (typed confirmation + approval)
├── environments/
│   ├── default/                        # Compute / network / storage stack
│   │   ├── provider.tf                 # provider + COS backend (prefix: terraform/default)
│   │   ├── variables.tf
│   │   ├── main.tf                     # Wires up modules/*
│   │   └── outputs.tf
│   └── identity/                       # IAM (Identity Center) stack
│       ├── provider.tf                 # COS backend (prefix: terraform/identity)
│       ├── variables.tf
│       ├── main.tf                     # SSO role configuration + policies + assignment
│       └── outputs.tf
├── modules/
│   ├── vpc/                            # VPC + Subnet
│   ├── security_group/                 # Security Group + Rule Set
│   ├── cvm/                            # CVM instance (auto-picks latest TencentOS image)
│   └── cos/                            # COS bucket (with SSE-COS encryption)
├── .gitignore
└── README.md
```

---

## Workflows

| Workflow | Trigger | Acts on | Approval | Purpose |
|---|---|---|---|---|
| `terraform-pr-check.yml` | Pull request | Read-only | None | fmt + init + validate + plan, posts plan diff back to PR |
| `terraform-apply.yml` | Push to `main` (paths: `environments/default/**`, `modules/**`) | `environments/default` | `production` env | Apply default stack |
| `terraform-destroy.yml` | Manual `workflow_dispatch` (must type `destroy`) | `environments/default` | `production` env | Destroy default stack |
| `identity-apply.yml` | Push to `main` (paths: `environments/identity/**`) | `environments/identity` | `identity-production` env | Apply identity stack |
| `identity-destroy.yml` | Manual `workflow_dispatch` (must type `destroy-identity`) | `environments/identity` | `identity-production` env | Destroy identity stack |

The two stacks are intentionally split:

- IAM changes (identity stack) and infrastructure changes (default stack) have different blast radius and different reviewers.
- A bug or rollback in one stack does not affect the other.
- Each stack writes to a separate state prefix in the same COS bucket.

---

## One-time setup

### 1. Create state-backend COS buckets

Each stack uses its own bucket, both in the **master Tencent Cloud account** so a single set of credentials works for everything. Manually create two private buckets in `ap-hongkong` **with versioning enabled and SSE-COS encryption**:

| Bucket | Used by | State prefix |
|---|---|---|
| `tfstate-tcctfplay-default-<MASTER_APPID>` | default stack | `terraform/default` |
| `tfstate-tcctfplay-identity-<MASTER_APPID>` | identity stack | `terraform/identity` |

Then update the `bucket` field in:

- `environments/default/provider.tf`
- `environments/identity/provider.tf`

> Terraform's `backend` block does not support variable interpolation, so the bucket name must be hard-coded per environment file.

### 2. Configure GitHub Secrets and Variables

**Settings → Secrets and variables → Actions**

#### Repo-level Secrets (used by both stacks)

Both stacks share one set of master-account credentials. The master account owns all state buckets, the Identity Center instance, and (in this demo) the default stack resources too. If you ever split stacks across multiple accounts, split the Secrets per stack as well.

| Name | Value |
|---|---|
| `TENCENTCLOUD_SECRET_ID` | Master-account API SecretId. Needs both Identity Center management permission and access to the state buckets. |
| `TENCENTCLOUD_SECRET_KEY` | Master-account API SecretKey. |
| `CVM_PASSWORD` | CVM login password. 8–30 chars, must include at least 3 of: lowercase / uppercase / digit / special character. |

#### Repo-level Variables (default stack)

`COS_BUCKET_NAME` is no longer required. The bucket name is auto-derived from `name_prefix` and the master account's APPID via the `tencentcloud_user_info` data source. To override (e.g. provide a longer custom name), pass `TF_VAR_cos_bucket_name`.

#### Repo-level Variables (identity stack)

| Name | Example | Notes |
|---|---|---|
| `IDENTITY_ZONE_ID` | `z-71c8dwf2w3q3` | Identity Center instance zone id. |
| `IDENTITY_PRINCIPAL_ID` | `u-2jt99e06qde1` | SSO user id to be granted the role. |
| `IDENTITY_TARGET_UIN` | `200048944863` | Member account UIN where the role applies. |

### 3. Create GitHub Environments

**Settings → Environments**

Create two environments:

| Environment | Used by | Suggested reviewers |
|---|---|---|
| `production` | default stack apply / destroy | You |
| `identity-production` | identity stack apply / destroy | You + a security reviewer |

For each environment, enable **Required reviewers** so apply / destroy pauses for manual approval.

---

## Day-to-day usage

### Recommended PR flow (default stack)

```bash
git checkout -b feature/add-resource
# edit code under environments/default or modules/
git commit -am "feat: add resource"
git push origin feature/add-resource
# open a PR
```

The `terraform-pr-check` workflow runs automatically and posts the plan diff as a PR comment. After review and merge to `main`, `terraform-apply.yml` triggers, waits for `production` approval, and runs apply.

### Identity stack changes

Edit anything under `environments/identity/`, push to `main`. `identity-apply.yml` triggers, waits for `identity-production` approval, then runs apply.

### Destroying a stack

Both destroy workflows are **manual** with double confirmation:

| Stack | Workflow | Confirmation string |
|---|---|---|
| default | `Terraform Destroy` | `destroy` |
| identity | `Identity Destroy` | `destroy-identity` |

In the GitHub UI: **Actions → select destroy workflow → Run workflow → enter the confirmation string → approve in the environment gate**.

---

## Default stack — what it provisions

A minimal demo footprint in `ap-hongkong`:

| # | Resource | Name | Key attributes |
|---|---|---|---|
| 1 | VPC | `demo-vpc` | `10.0.0.0/16` |
| 2 | Subnet | `demo-subnet` | `10.0.1.0/24` in `ap-hongkong-2` |
| 3 | Security Group | `demo-sg` | Ingress: deny all (no rules) |
| 4 | SG Rule Set | derived | Egress: ICMP + UDP/53 only (allows `ping` + DNS lookup) |
| 5 | EIP | auto-attached | 5 Mbps cap, public IP |
| 6 | CVM | `demo-cvm` | `SA2.MEDIUM2` (2C2G), TencentOS Server 3.x |
| 7 | System disk | implicit | 50 GB `CLOUD_PREMIUM` |
| 8 | COS Bucket | `${COS_BUCKET_NAME}` | Private + Versioning + SSE-COS (AES256) |

Default tags are intentionally empty (`{}`) to avoid Tencent Cloud reserved tag prefix conflicts (`cos:`, `qcs:`, etc.). To re-enable tags, use lowercase keys with no colons.

---

## Identity stack — what it provisions

In the master account's Identity Center:

| # | Resource | Purpose |
|---|---|---|
| 1 | `tencentcloud_identity_center_role_configuration` | Creates a role configuration named `cdb_admin` |
| 2 | `..._permission_policy_attachment` | Attaches a pre-defined policy (e.g. `219185po` = QcloudCDBFullAccess) |
| 3 | `..._permission_custom_policy_attachment` | Attaches a custom policy `vpc-admin` granting `vpc:*` |
| 4 | `tencentcloud_identity_center_role_assignment` | Assigns the role to a SSO user, scoped to a member account |

All sensitive identifiers (`zone_id`, `principal_id`, `target_uin`) are injected via GitHub Variables — nothing is hard-coded.

---

## Local debugging

For one-off ad-hoc debugging only. Production changes always go through the pipeline.

```bash
# Default stack
cd environments/default

export TENCENTCLOUD_SECRET_ID=xxx
export TENCENTCLOUD_SECRET_KEY=xxx
export TF_VAR_cvm_password='YourStrong#Passwd1'
# Optional override; leave unset to auto-derive as ${name_prefix}-app-<APPID>
# export TF_VAR_cos_bucket_name='tfplay-demo-1426280973'

terraform init
terraform plan
# Avoid running terraform apply locally — it bypasses the production approval gate.
```

```bash
# Identity stack
cd environments/identity

export TENCENTCLOUD_SECRET_ID=xxx     # master account
export TENCENTCLOUD_SECRET_KEY=xxx
export TF_VAR_zone_id=z-xxxxxxxx
export TF_VAR_principal_id=u-xxxxxxxx
export TF_VAR_target_uin=2000xxxxxxxx

terraform init
terraform plan
```

---

## Security notes

- **Never commit credentials.** No `secret_id` / `secret_key` in any `.tf` file. They flow only through GitHub Secrets → environment variables.
- **State backend versioning is mandatory** so a corrupt state can be rolled back.
- **State backend uses SSE-COS by default** (configured at the bucket level when you create it).
- **Terraform state contains sensitive values** (e.g. CVM password) — keep state-bucket access restricted to the CI runner.
- **Identity stack must use a master-account credential** with Identity Center permissions. Default stack can use a member-account credential with least-privilege scope.
- **Reserved tag prefixes**: Tencent Cloud rejects tag keys with prefixes like `cos:`, `qcs:`, `tke:`, `cls:`, `cdb:`. Use lowercase keys without colons (e.g. `project`, `managed-by`).
- **For production**: replace CVM password login with `tencentcloud_key_pair` (key-pair login). Password auth should not survive past demo phase.

---

## Cross-account reuse

To reuse this repo against another Tencent Cloud account without forking:

1. Create a new state bucket in the target account (with that account's APPID suffix).
2. Update the `bucket` value in `environments/default/provider.tf` and / or `environments/identity/provider.tf`.
3. Add a new GitHub Environment (e.g. `account-b-production`) with reviewers and per-environment Secrets:
   - `TENCENTCLOUD_SECRET_ID` (account B credential)
   - `TENCENTCLOUD_SECRET_KEY`
   - etc.
4. Create a copy of the workflow that points to the new environment, or extend the workflow with a `workflow_dispatch` `environment` input.

For a more scalable pattern, copy `environments/default/` to `environments/account-b/` with its own `provider.tf` and `terraform.tfvars`, and parameterize the workflows by environment.
