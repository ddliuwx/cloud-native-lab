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
5. **命名规范 (naming convention)**：local name 用 snake_case，且不重复 resource type（如 `aws_iam_role.ec2_s3_readonly` 而不是 `aws_iam_role.ec2_s3_readonly_role`）；同一 module 内只有一个某类型资源时可参考 HashiCorp 官方惯例命名为 `this`；AWS-facing 的 `name` 属性用 kebab-case，加项目前缀但不塞 metadata（metadata 放 tags）。重命名 local name 时记得同步 `terraform state mv`，否则会触发不必要的 destroy+create。

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

- **VPC (Virtual Private Cloud，虚拟私有云)**：云上一个逻辑隔离的网络环境，你可以在里面自定义 IP 地址段、子网、路由规则。
- **Subnet /ˈsʌbˌnet/（子网）**：VPC 内划分出的更小网段，通常分为 public subnet（可直接访问公网）和 private subnet（不能直接被公网访问）。public subnet 需要同时具备"public IP"和"到 internet gateway 的 route"两个条件才能双向访问公网，二者缺一都会导致隔离。
- **CIDR /ˈsaɪdər/（无类别域间路由）**：一种表示 IP 地址段范围的写法，例如 `10.0.0.0/16`。
- **Security Group（安全组）**：绑定在 instance 层面的 **stateful（有状态）** 虚拟防火墙，inbound 放行后 return traffic 自动放行，无需单独配 outbound。
- **NACL /ˈnækəl/（Network ACL）**：绑定在 subnet 层面的 **stateless（无状态）** 防火墙，inbound/outbound 必须分别显式配置，支持 explicit deny。常见坑：忘记放行 outbound 的 ephemeral port range（1024-65535）会导致 response 发不出去。另一个坑：`aws_network_acl` 的 `protocol` 字段要用 IANA protocol number（如 `"6"` 代表 TCP），不是 `"tcp"` 这种友好名字（这是 `aws_network_acl_rule` 才支持的写法）。
- **NAT Gateway /næt ˈɡeɪtweɪ/**：让 private subnet 里的资源能单向发起 outbound 连接（比如下载更新），但外部无法主动连入；按小时+流量计费，容易忘记删。
- **AMI /eɪ em aɪ/（Amazon Machine Image）**：EC2 instance 的 OS 模板，建议用 `data "aws_ami"` 动态查询最新版本，而不是写死 AMI ID（AMI ID 因 region 而异、且会过期）。
- **`user_data` / cloud-init /klaʊd ɪˈnɪt/**：EC2 第一次启动时自动执行的 bootstrap script，由预装的 cloud-init 工具读取并当 shell script 执行（脚本开头需要 `#!/bin/bash`）。**只在首次启动时跑一次**，reboot/stop-start 不会重新执行。
- **Key pair（密钥对）**：SSH 登录用的一对密钥，public key 上传给 AWS（`aws_key_pair`），private key 留在本地。`aws_instance` 的 `key_name` 属性是 **ForceNew**——运行中的实例改 key 会触发 replace（先 destroy 再 create，public IP 也会跟着变）。
- **`metadata_options`（IMDSv2 hardening）**：给 `aws_instance` 加 `http_tokens = "required"` 可以强制要求 token-based 的 **IMDSv2**，屏蔽掉不安全的 IMDSv1（历史上 Capital One 数据泄露就是 IMDSv1 被 SSRF 攻击利用导致的）。这个属性支持**原地更新**（1 to change，不是 replace）——同样是改 EC2 属性，是 update 还是 replace 取决于 AWS API 本身支不支持"运行中修改"，不是 Terraform 自己规定的。
- **Stop vs Terminate**：stop 只是关机，根 EBS volume 数据保留、不再为 compute 计费；terminate 才会连磁盘一起删除。**Stop/start 之后，动态 public IP 会变**（除非用 Elastic IP 固定），但磁盘数据（包括 `user_data` 装好的软件）会完整保留。Power state 是运行时操作，不属于 Terraform 管理的目标配置范畴，需要用 AWS CLI 单独操作。
- **IAM Role vs User**：User 对应"人"，有长期 credentials；Role 没有固定凭证，靠 **trust policy（信任策略，回答"谁能 assume"）**决定谁能"假设"它，assume 成功后拿到的是**临时凭证**，用完自动过期。**Permission policy（权限策略）**回答"assume 成功后能做什么"，两者缺一不可。
- **Least privilege（最小权限原则）**：只给"刚好够用"的权限，没写明的 action 默认 **`implicitDeny`（隐式拒绝）**，不需要专门写 deny 规则。可以用 `aws iam simulate-principal-policy` 在不真的起资源的情况下验证 policy 设计对不对。
- **OIDC federation /oʊaɪdiːsiː ˌfedəˈreɪʃn/（联合身份认证）**：让 GitHub Actions 这类外部系统凭一个短期 JWT token 换取 AWS 临时凭证，全程不需要在外部系统里存长期 Access Key。GitHub 侧对应 `aws_iam_openid_connect_provider` + trust policy 里用 `sub`/`aud` claim 做 condition 限制范围（比如精确限制到某个 repo）。
- **`terraform state mv`**：只改 local name（不改实际云资源）时，必须同步执行这个命令告诉 state file"这是同一个资源改了名字"，否则 Terraform 会误判成"旧资源被删、新资源要建"，触发不必要的 destroy+create。`data` block 不受影响（本来就不持有真实资源）。

## 当前进度 (Current Progress)

- **2026-07-06**：Phase 0 基本完成。Terraform CLI 已安装（v1.14.8）。完成了 `local_file` 资源的 init/plan/apply/destroy 练习、variable/output 改造、`-var` 覆盖 default 练习，并理解了 replace（强制重建）vs update（原地更新）的区别。
- **2026-07-06**：Phase 1（远程 backend）完成。用 bootstrap/app 两个 root module 的模式创建了 S3 + DynamoDB backend，验证了 state 确实存到了 S3 上（本地不再有 tfstate 文件），并完整走了一遍销毁流程（含 `force_destroy` 处理 versioning 导致的非空 bucket 问题）。
- **2026-07-07**：Phase 2（网络）完成，含两个扩展实验。搭建了含 public/private subnet 的最小 VPC 拓扑（VPC + IGW + 2 subnet + route table + security group），验证了 private subnet 因为缺少 public IP + IGW route 而双向隔离；做了 NACL 对比练习（stateful vs stateless，踩了 protocol number 的坑）；短时验证了 NAT Gateway（EIP + NAT GW + private route table 指向 NAT），确认 route 生效后立刻 destroy，12 个资源全部清理干净且验证无残留（含最容易漏删的 Elastic IP）。
- **2026-07-07**：Phase 3（计算 EC2）完成，含两个扩展实验。用 default VPC + data source 动态查 AMI + `user_data` 起了一台 EC2，装 nginx 并通过 curl 验证；加了 key pair 做 SSH 验证（体验了一次 `key_name` 触发的 ForceNew replace）；做了 IMDSv2 hardening（体验了属性可以原地更新 vs 强制重建的对比）；用 AWS CLI 做了 stop/start，验证了动态 public IP 会变、但磁盘数据持久化。全部资源 + 本地 SSH key 已清理干净。
- **2026-07-07**：Phase 4（IAM 与安全）完成。搭了一个 EC2→S3 只读的最小权限 role（instance profile 模式），用 `aws iam simulate-principal-policy` 验证了 least privilege 边界（允许的 allowed，没提到的 implicitDeny）；搭了 GitHub Actions OIDC role（trust policy 精确锁定到 `repo:ddliuwx/cloud-native-lab`，permission 故意先给到最小，等 Phase 9 真正需要时再加）；顺手做了一次 local name 重命名的重构练习，学会了用 `terraform state mv` 避免不必要的 destroy+create。全部 8 个 IAM 资源已清理并校验干净。KMS/aws-vault 探索和腾讯云 CAM 对照练习待定。下一步：Phase 5（存储与数据库）。
