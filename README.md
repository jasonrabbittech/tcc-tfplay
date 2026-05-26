# Tencent Cloud Terraform GitOps Demo

基于 GitHub Actions 的腾讯云 Terraform CI/CD pipeline，参考腾讯云官方 [gitops-terraform](https://github.com/tencentcloudstack/gitops-terraform) 风格组织，演示 VPC / Subnet / Security Group / CVM / COS 五类基础资源的全自动创建与变更管理。

## 目录结构

```
.
├── .github/
│   └── workflows/
│       ├── terraform-pr-check.yml   # PR 触发：fmt + init + validate + plan，结果回评 PR
│       └── terraform-apply.yml      # 合并到 main 触发：init + plan + apply（需 Environment 审批）
├── environments/
│   └── default/                     # 单环境根模块（先简单起步）
│       ├── provider.tf              # provider + COS backend
│       ├── variables.tf
│       ├── main.tf                  # 引用 modules/*
│       ├── outputs.tf
│       └── terraform.tfvars.example
├── modules/
│   ├── vpc/                         # VPC + Subnet
│   ├── security_group/              # 安全组 + 规则集
│   ├── cvm/                         # CVM 实例（自动取最新 TencentOS 镜像）
│   └── cos/                         # COS Bucket
├── .gitignore
└── README.md
```

## 一次性准备

### 1. 创建 COS Bucket 作为 Terraform Backend

在腾讯云控制台或 CLI 创建一个独立的 COS Bucket 用于存储 state（**不要**和业务用的 COS 复用）：

```bash
# 区域：ap-hongkong
# Bucket 名称：tfstate-<your-name>-<appid>
# 务必开启版本控制
```

然后修改 `environments/default/provider.tf` 中的 `bucket` 字段为实际名称。

### 2. 在 GitHub 仓库配置 Secrets / Variables

**Settings → Secrets and variables → Actions**

| 类型 | 名称 | 说明 |
|------|------|------|
| Secret | `TENCENTCLOUD_SECRET_ID` | 腾讯云 API 密钥 ID |
| Secret | `TENCENTCLOUD_SECRET_KEY` | 腾讯云 API 密钥 Key |
| Secret | `CVM_PASSWORD` | CVM 登录密码（≥12 位，含大小写+数字+特殊字符） |
| Variable | `COS_BUCKET_NAME` | 业务用 COS Bucket 名称，例如 `demo-app-1250000000` |

### 3. 配置 Production Environment（用于人工审批）

**Settings → Environments → New environment → 命名为 `production`**

启用 **Required reviewers**，添加你自己作为审批人。Apply workflow 触发后会暂停等待审批。

## 使用方式

### PR 流程（推荐）

```bash
git checkout -b feature/add-cvm
# 修改代码
git commit -am "add cvm"
git push origin feature/add-cvm
# 在 GitHub 上发起 PR
```

PR 创建后自动触发 `terraform-pr-check`，plan 结果会以 comment 形式贴在 PR 上。Review 通过后合并到 main，自动触发 `terraform-apply`，等待 production environment 审批通过后执行 apply。

### 本地调试

```bash
cd environments/default
cp terraform.tfvars.example terraform.tfvars   # 按需修改

export TENCENTCLOUD_SECRET_ID=xxx
export TENCENTCLOUD_SECRET_KEY=xxx
export TF_VAR_cvm_password='YourStrong#Passwd1'

terraform init
terraform plan
terraform apply
```

## 资源说明

| 模块 | 资源 | 说明 |
|------|------|------|
| `vpc` | `tencentcloud_vpc`, `tencentcloud_subnet` | 默认 10.0.0.0/16，子网 10.0.1.0/24 |
| `security_group` | `tencentcloud_security_group`, `tencentcloud_security_group_rule_set` | 默认放通 22/80 入站、全部出站 |
| `cvm` | `tencentcloud_instance` + `data.tencentcloud_images` | 默认 S5.MEDIUM2 + TencentOS Server 3.1 + 50G 高性能云盘 |
| `cos` | `tencentcloud_cos_bucket` | 默认 private + 开启版本控制 |

## 安全提醒

- `terraform.tfvars` 已加入 `.gitignore`，**绝不要**把它提交到仓库
- `CVM_PASSWORD` 只通过 GitHub Secret + `TF_VAR_*` 环境变量注入，不进 state 以外的任何文件
- COS backend Bucket 务必开启版本控制，state 损坏时可回滚
- 生产环境建议把 CVM 密码登录改为 `tencentcloud_key_pair` 密钥对登录
