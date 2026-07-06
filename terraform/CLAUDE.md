# Terraform 学习计划 (Terraform Learning Plan)

## 项目背景 (Background)

这个仓库用于系统性练习 Terraform，目标是达到新西兰（New Zealand）Cloud Engineer 岗位招聘中对 Terraform / IaC (Infrastructure as Code，基础设施即代码) 的常见要求。

使用的云平台（均为个人账号 / personal accounts）：
- **AWS** — 主线平台，新西兰招聘中出现频率最高
- **腾讯云 (Tencent Cloud)** — 辅助/对照平台，费用更低，用来强化"provider-agnostic（与具体云无关）"的抽象理解

## 协作约定 (Collaboration Conventions)

1. **命令行由学习者本人执行**：所有 `terraform init/plan/apply/destroy`、`aws configure`、`tccli configure` 等命令，Claude 只给提示，不代为执行；学习者手动跑并回报结果。
2. **代码示例以提示为主**：基础语法阶段（Phase 0）会给完整示例帮助建立语感；进入模块化/多环境等阶段后逐渐减少完整代码，更多给"骨架 + 需要你填的部分"。
3. **双语讲解风格 (Bilingual style)**：
   - 句子结构以中文为主，穿插英文技术词汇和短语（不要整段整段英文）。
   - 每条消息中，英文词汇/词组第一次出现时标注国际音标 IPA，例如 drift /drɪft/（漂移），同一条消息里重复出现不用再标。
   - 专有名词 (proper nouns / technical terms，如 VPC、subnet、state file) 需要给出**中英文对照的专业解释**，不是简单翻译，而是讲清楚它是什么、为什么存在。新术语出现时补充进下面的术语表 (Glossary)。
4. **及时校验**：每个 Phase 结束前跑一遍 `terraform destroy`，确认没有遗留资源。

## 成本控制原则 (Cost Control Principles)

- 每个实验做完立即销毁资源 (destroy immediately after each lab)，不留资源过夜。
- Apply 前开启 **AWS Budgets / Billing Alarms** 和腾讯云费用预警。
- 避免长期占用计费的资源：
  - AWS **NAT Gateway**（按小时 + 流量计费，非常容易忘记删）
  - **EKS / TKE 控制平面**（约 $0.10/小时 ≈ $72/月），仅在容器编排阶段短暂开启验证一次，立即销毁
  - 数据库类资源使用最小规格，且用完即删
- 优先选用天然低成本的服务练手：Lambda / SCF（Serverless Cloud Function）、S3/COS、DynamoDB 按量计费部分。

## 新西兰 Cloud Engineer 岗位要求归纳 (Summary of Common NZ Job Requirements)

综合本地（Wellington/Auckland 常见雇主，如系统集成商、金融、政府相关承包商）招聘 JD 的共性要求：

| 类别 | 具体要求 |
|---|---|
| IaC | Terraform（首选）、部分岗位提及 CloudFormation/Pulumi |
| 云平台 | AWS 为主，部分岗位要求 Azure；GCP 较少 |
| 网络 (Networking) | VPC 设计、子网划分、路由、VPN/Direct Connect、Security Group/NACL |
| 计算/容器 | EC2/ECS/EKS，Docker，Kubernetes、Helm |
| CI/CD | GitHub Actions / GitLab CI / Azure DevOps / Jenkins |
| 脚本能力 | Python、Bash（有时 Go） |
| 安全 (Security) | IAM 最小权限原则、Secrets 管理（Vault / Secrets Manager）、加密（传输中与静态数据） |
| 合规 (Compliance) | 部分政府相关岗位提及 NZISM（新西兰信息安全手册）等标准 |
| 监控/可观测性 | CloudWatch、Datadog、Prometheus/Grafana |
| 成本管理 (FinOps) | 标签策略 (tagging)、预算告警、资源生命周期管理 |
| 协作方式 | Agile/Scrum，与开发团队协作交付基础设施 |
| 认证 (加分项) | AWS Certified Solutions Architect / DevOps Engineer、HashiCorp Terraform Associate |

下面的学习路线图按这些要求设计，每个 Phase 标注对应的招聘要求类别。

## 学习路线图 (Roadmap)

### Phase 0 — Terraform 基础 (Fundamentals)
- 对应要求：IaC 基础语法
- 内容：provider、resource、state file、`init/plan/apply/destroy` 生命周期、variable/output
- 实验：本地 `local_file` 资源练习（零成本）
- 交付物：能独立解释 state file 的作用、能写基本 HCL

### Phase 1 — 远程状态 (Remote Backend)
- 对应要求：IaC 基础、团队协作下的状态管理
- AWS：S3 + DynamoDB（state locking，状态锁）
- 腾讯云：COS 对象存储做 backend
- 交付物：理解为什么团队协作必须用 remote backend 而不是本地 state

### Phase 2 — 网络 (Networking)
- 对应要求：Networking（VPC、子网、路由、安全组）
- AWS：VPC / Subnet / Route Table / Security Group
- 腾讯云：VPC / 子网 / 路由表 / 安全组（对照练习）
- 成本提醒：避免创建 NAT Gateway
- 交付物：能画出并解释一个含公有/私有子网的最小 VPC 拓扑

### Phase 3 — 计算 (Compute)
- 对应要求：计算资源管理
- AWS：EC2（t2.micro/t3.micro，Free Tier）
- 腾讯云：CVM（最低配置）
- 交付物：用 Terraform + `user_data` 起一台带初始化脚本的实例

### Phase 4 — IAM 与安全 (IAM & Security)
- 对应要求：Security（最小权限、Secrets 管理）
- AWS：IAM Role / Policy / KMS
- 腾讯云：CAM（访问管理）/ KMS
- 交付物：为后续 CI/CD 设计一个最小权限的 IAM Role

### Phase 5 — 存储与数据库 (Storage & Database)
- 对应要求：计算/数据管理
- AWS：S3、RDS（db.t3.micro Free Tier）
- 腾讯云：COS、TencentDB
- 交付物：理解数据库类资源的成本注意事项

### Phase 6 — 无服务器 (Serverless)
- 对应要求：现代云架构常见形态，成本最友好
- AWS：Lambda + API Gateway
- 腾讯云：SCF + API 网关
- 交付物：一个事件驱动的最小函数应用

### Phase 7 — 模块化 (Modules)
- 对应要求：IaC 工程化能力（团队协作、复用）
- 内容：把 Phase 2-6 资源重构为可复用 module
- 交付物：`modules/vpc`, `modules/ec2` 等可复用模块

### Phase 8 — 多环境管理 (Multi-environment)
- 对应要求：团队协作下的 dev/staging/prod 隔离
- 内容：workspace vs 目录分层两种模式对比
- 交付物：一套支持多环境的目录结构

### Phase 9 — CI/CD 集成
- 对应要求：CI/CD 工具链
- 内容：GitHub Actions 跑 `terraform fmt/validate/plan`，PR 自动评论 plan 结果；AWS 侧使用 OIDC 联合身份登录（无长期 Access Key）
- 交付物：一条完整的 IaC CI/CD pipeline

### Phase 10 — 测试与安全扫描 (Testing & Security Scanning)
- 对应要求：Security、质量保障
- 工具：`tflint`、`checkov` 或 `tfsec`
- 交付物：CI 中集成静态安全扫描

### Phase 11 — 容器编排 (Container Orchestration)
- 对应要求：容器（Docker、Kubernetes）
- AWS：ECS Fargate（优先，较便宜）、EKS（谨慎，短时验证即销毁）
- 腾讯云：TKE
- 交付物：一个跑在 Fargate 上的容器化服务

### 毕业项目 (Capstone Project)
在 AWS 上用 Terraform 模块化搭建最小三层 Web 架构：VPC + ALB + ECS Fargate/ASG + RDS，配合远程 state 和 GitHub Actions CI/CD。可直接作为求职作品集 (portfolio) 使用。

## 术语表 (Glossary)

已覆盖的术语（持续补充，新术语随学习进度追加）：

- **Provider /prəˈvaɪdər/（提供者/插件）**：Terraform 用来对接某个平台 API 的插件，比如 `hashicorp/aws`、`hashicorp/local`。
- **Resource /ˈriːsɔːrs/（资源）**：Terraform 管理的一个具体对象，语法为 `resource "<类型>" "<本地名称>" { ... }`。
- **State file /steɪt faɪl/（状态文件）**：Terraform 用来记录"当前实际创建了什么资源、它们的属性是什么"的账本文件（`terraform.tfstate`），是 Terraform 判断 plan/apply 要做什么变更的依据。
- **Lineage /ˈlɪniɪdʒ/（谱系/世系）**：state 文件的唯一 identifier，防止不同项目的 state 被误合并。
- **Drift /drɪft/（漂移）**：实际云上资源状态与 Terraform 配置/state 记录不一致的现象。
- **Idempotency /ˌaɪdəmˈpoʊtənsi/（幂等性）**：同一份配置反复执行 `apply`，结果保持一致，不会重复创建或产生副作用。
- **Variable / Output（变量 / 输出）**：variable 是可配置的输入参数，output 是 apply 后暴露出来供人或其他模块读取的值。
- **Replace / Force Replacement（替换/强制重建）**：当某个属性变化无法用 Update 操作完成时，Terraform 会先 destroy 旧资源再 create 新资源；plan 输出里会用 `-/+` 符号和 "forces replacement" 提示标记，apply 结果统计上表现为 "X added, X destroyed"（不计入 changed）。
- **Backend /ˈbækˌend/（后端存储）**：state 文件存放的位置，可以是本地磁盘，也可以是远程存储（如 S3、COS），团队协作场景必须用远程 backend。backend block 里不能用 variable（必须写死字符串），因为 backend 初始化发生在 variable 解析之前。
- **State locking（状态锁）**：防止多人同时 apply 导致 state 文件损坏的锁机制。用 DynamoDB 实现时，原理是往一张表里写一条 `LockID` 记录，apply 完成后自动删除；Terraform 1.10+ 也支持不依赖 DynamoDB 的 S3 原生锁（`use_lockfile = true`）。
- **Bootstrap /ˈbuːtstræp/（自举/引导）模式**：backend 本身需要的资源（S3 bucket、DynamoDB table）不能用它们自己管理的 state 来创建（循环依赖/chicken-and-egg problem），所以要用一个单独的、本地 state 的 root module 先创建好这些资源。
- **`force_destroy`**：S3 bucket 默认不允许删除非空 bucket（尤其开了 versioning 后，历史版本也算"非空"），要在 destroy 前把这个属性设为 `true` 并重新 apply，才能让 Terraform 自动清空 bucket 再删除。

即将用到的术语（Phase 2 预告）：
- **VPC (Virtual Private Cloud，虚拟私有云)**：云上一个逻辑隔离的网络环境，你可以在里面自定义 IP 地址段、子网、路由规则。
- **Subnet /ˈsʌbˌnet/（子网）**：VPC 内划分出的更小网段，通常分为 public subnet（可直接访问公网）和 private subnet（不能直接被公网访问）。
- **CIDR /ˈsaɪdər/（无类别域间路由）**：一种表示 IP 地址段范围的写法，例如 `10.0.0.0/16`。
- **Security Group（安全组）**：绑定在实例上的虚拟防火墙规则，控制进出流量。

## 当前进度 (Current Progress)

- **2026-07-06**：Phase 0 基本完成。Terraform CLI 已安装（v1.14.8）。完成了 `local_file` 资源的 init/plan/apply/destroy 练习、variable/output 改造、`-var` 覆盖 default 练习，并理解了 replace（强制重建）vs update（原地更新）的区别。
- **2026-07-06**：Phase 1（远程 backend）完成。用 bootstrap/app 两个 root module 的模式创建了 S3 + DynamoDB backend，验证了 state 确实存到了 S3 上（本地不再有 tfstate 文件），并完整走了一遍销毁流程（含 `force_destroy` 处理 versioning 导致的非空 bucket 问题）。下一步：Phase 2（网络 VPC/Subnet/Security Group）。
