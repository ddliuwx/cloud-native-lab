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
6. **提交前格式化 (fmt before commit)**：每次 `git commit` 推到 GitHub 之前，先跑一遍 `terraform fmt -recursive`，确认没有格式改动（或格式改动已经加入本次 commit）再提交，避免 CI 里的 `terraform fmt -check` 报错、也保持代码风格统一。
7. **全部改动走 PR (PR-only workflow)**：从 Phase 9 之后，所有改动都不再直接 push 到 `main`，一律走"新建 feature 分支 → push → 开 PR → 等 CI 检查 → merge"的完整流程；Claude 负责建分支、commit、push、开 PR（可用 `gh pr create`），**merge 这一步固定由学习者本人在 GitHub 网页上手动点击**，用来专门练习 PR 的 review/merge 环节。

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
- **Lifecycle rule（生命周期规则）**：给 S3 object 设置自动过期/转存规则。较新版本的 `aws_s3_bucket_lifecycle_configuration` 要求每个 `rule` 显式带 `filter`（哪怕是空 `filter {}`，表示适用于整个 bucket），否则会有 deprecation warning。
- **Bucket policy vs IAM policy**：都是权限策略，但挂载位置不同——IAM policy 挂在 role/user 身上（"这个身份能干什么"），bucket policy 直接挂在 bucket 自己身上（"谁能访问这个 bucket"），两者同时存在时取交集。
- **RDS 成本模型**：`db.t3.micro` 按小时计费，storage 按 GB-month 计费，**Multi-AZ 会让两者都翻倍**（学习阶段应保持单 AZ）；create/destroy 都要 5-15 分钟，是目前遇到过最慢的资源类型。`skip_final_snapshot = true` 能避免删除前多等一次最终快照、也避免留下一个继续计费的 snapshot。
- **`manage_master_user_password`**：让 AWS 自动生成 RDS 密码并存入 **Secrets Manager**，全程不经手明文，用 `aws secretsmanager get-secret-value` 取用。这类自动生成的 secret 命名固定带 `!`（如 `rds!db-xxx`），在 zsh 里会触发 **history expansion**，要用单引号包住，或者干脆换个不含 `!` 的查询条件绕开。
- **`backup_retention_period` 默认值是 `0`**：默认关闭自动备份，必须显式设置（如 `= 7`）才有灾难恢复能力——这是个容易被忽略的不安全默认值。
- **`apply_immediately`**：和"update vs replace"是两个不同维度的问题——它决定的是修改**什么时候**生效（立刻 vs 排到下一个 maintenance window），不是**怎么**生效。可以用 `aws rds describe-db-instances` 的 `PendingModifiedValues` 字段看到"已接受但未生效"的排队中修改。
- **Lambda /ˈlæmdə/**：serverless 计算服务，按调用次数 + 运行时长计费，有永久性 always-free 额度（每月 100 万次调用）。**Cold start（冷启动）**：长时间未调用后第一次请求会多花时间初始化运行环境。
- **`archive_file`（archive provider）**：把本地代码文件打包成 zip 供 Lambda 部署用，`source_file`（单文件）和 `source_dir`（整个目录）不能混用，混用会报 "could not archive directory that is a file" 之类的错。
- **Resource-based policy vs Identity-based policy**：Phase 4 学的 IAM policy 挂在 role/user 身上是 identity-based（"这个身份能做什么"）；`aws_lambda_permission`、S3 bucket policy 这类直接挂在资源自己身上的，是 resource-based（"谁能访问/调用我"），回答的问题方向相反。
- **API Gateway HTTP API vs REST API**：HTTP API（`aws_apigatewayv2_*`）更新、更便宜、配置更简单，新项目首选；REST API（`aws_api_gateway_*`）功能更全但配置更复杂，多见于遗留项目。
- **`depends_on`（显式依赖）**：当两个 resource 之间存在"AWS API 层面要求的顺序"，但彼此配置里没有互相引用对方属性时，Terraform 没法自动推断依赖关系，必须手动声明。典型场景：`aws_s3_bucket_notification` 必须等 `aws_lambda_permission` 先创建好，否则 AWS 会拒绝这个 notification 配置。
- **S3 event notification（事件驱动）**：S3 对象上传等事件可以直接触发 Lambda，属于异步 (asynchronous) 触发，跟 API Gateway 那种同步 (synchronous) 的"请求-响应"模式是两种不同的 serverless 触发方式。
- **Module /ˈmɒdjuːl/（模块）**：一组打包在一起、可复用的 resource 集合。`source` 参数告诉 Terraform 去哪找它（本地相对路径 / Git / Registry）。你直接 apply 的是 **root module**，被它调用的是 **child module**。
- **`module.<名字>.<output>`**：引用某个 module 的 output 的语法，用来把一个 module 的输出传给另一个 module 当输入（module 组合/composition）。新增或删除 module 后要重新 `terraform init`。
- **Module 的职责边界**：module 应该只管好自己范围内的事，不要替调用者做决定——比如 `modules/vpc` 不应该内置 Security Group，因为"开哪些 port"是消费这个网络的人（EC2/ALB）该决定的事，不是网络本身的属性；但如果这个属性是资源本身固有的（比如 RDS 该开哪个 DB port），module 自己拥有就是合理的，边界判断要看"这是谁的责任"，没有一刀切的规则。
- **`for_each`**：让一个 resource 根据一个 set/map 重复创建多份实例。**坑点**：如果 `for_each` 用的是 `toset(list)`，而 list 里的元素本身是"还没创建、值未知"的资源属性（比如另一个还没 apply 的 resource 的 `.arn`），会报错——因为 set 的 key 就是元素本身，key 在 plan 阶段必须确定。解法是转成 map，让 key 用静态已知的东西（比如 index），只让 value 是可能未知的：`{ for idx, arn in var.list : tostring(idx) => arn }`。
- **`count`**：更简单的重复机制，常用来做"要不要创建这个 resource"的条件开关（`count = 条件 ? 1 : 0`）。用了 `count` 之后，这个 resource 在其他地方被引用时会变成一个**列表**，要用 `[0]` 取值，且要考虑"列表可能是空的"这种情况。
- **`try()`**：包一层来处理"取值可能失败"的场景（比如引用一个 `count` 可能为 0 的 resource 的属性），失败时返回你指定的备用值，而不是让整个 apply 报错中断。
- **RDS subnet group 的隐藏要求**：哪怕最终只想单 AZ 部署，`aws_db_subnet_group` 本身也**必须**横跨至少 2 个 Availability Zone，不然会报 `DBSubnetGroupDoesNotCoverEnoughAZs`。而且这些 subnet 如果想让 `publicly_accessible = true` 真正生效，也得是有 IGW route 的 public subnet——跟 Phase 2 学的"public IP + IGW route 缺一不可"是同一个逻辑，只是这次是 subnet group 层面的坑。
- **Workspace /ˈwɜːrkspeɪs/（工作区）**：同一份代码切出多份独立 state，但**共用同一个 backend 配置**。内置变量 `terraform.workspace` 不用声明直接能读。本地 state 时，各 workspace 的 state 实际存在 `terraform.tfstate.d/<workspace名>/` 下，物理隔离但共享 backend。最大风险：代码和命令长得完全一样，切错 workspace 容易在不知情的情况下操作错环境。
- **目录分层 (directory layering)**：每个环境一个独立目录/root module，天然独立 state，还能指向完全不同的 backend、不同的 AWS 账号，靠物理上"人在哪个目录"防止误操作，是比 workspace 更强的隔离方式，HashiCorp 官方现在也更推荐用它做 prod 级别的隔离；workspace 更适合临时性、短生命周期的环境。
- **持久化的 IAM role（persistent resource，例外情况）**：Phase 9 的 GitHub OIDC role 是本学习计划里第一个刻意**不 destroy**、长期留着的资源——因为 GitHub Actions 每次跑 pipeline 都要 assume 这个 role 才能拿到 AWS 临时凭证，而 IAM role/policy 本身不计费，"长期存在"不违反成本控制原则，只是打破了"每个实验做完立即销毁"这一条默认习惯。
- **`permissions: id-token: write`**：GitHub Actions workflow 级别的权限声明，授权这次 job 生成一个 OIDC ID token；没有它，`aws-actions/configure-aws-credentials` 换取不到 token，OIDC 认证会直接失败。
- **`continue-on-error: true`**：让某个 step 即使失败也不中断整个 job（后续 step 照常执行），但会把这个 step 标记为失败，可通过 `steps.<id>.outcome` 读到。Phase 9 里用在 `fmt`/`plan` 上，是为了让流程能走到"评论 PR"这一步，再用单独的 `Fail if plan failed` step 来决定 job 整体成不成功——即 fmt 格式问题不应该挡住 plan 结果被看到，但 plan 本身失败必须让 job 标红。
- **module 的保留字段 `version`**：跟自定义 variable 撞名的坑——`version` 是 module block 自带的 meta-argument（用来约束 Terraform Registry 模块的版本号，如 `version = "~> 1.0"`），如果你自己的 module 也想要一个叫 `version` 的输入变量会被 Terraform 当成这个保留字段解析，报 "Invalid version constraint"。避免和 Terraform 保留字段撞名（`source`、`version`、`providers`、`count`、`for_each`、`depends_on`、`lifecycle` 都是 module block 保留的）。
- **CI 只跑 `plan`、不跑 `apply` 的设计**：行业里对生产环境 IaC pipeline 的常见默认做法——`plan` 可以在 PR 阶段自动跑并评论结果，方便 reviewer 在合并前看到即将发生的变更；`apply` 保留人工触发（手动点击、或者合并到 `main` 后单独一个需要 approval 的 job），避免自动化流程未经复核就改动真实基础设施。
- **`tflint`**：Terraform 专用的 **linter**，偏"代码质量"——比如缺 `required_version`/`required_providers` 版本约束、命名规范问题，不检查安全配置。`terraform-linters/setup-tflint` 这个官方 GitHub Action 可以在 CI 里直接装二进制，避免本地 Homebrew tap 那种匿名 HTTPS clone 网络问题。
- **`checkov`**：**policy-as-code** 安全扫描工具，专门抓 misconfiguration（配置错误），跟 tflint 是完全不同的维度。有两类 check：普通的单资源 check（`CKV_AWS_*`）和跨资源的 **graph check**（`CKV2_AWS_*`，比如"S3 bucket 是否有 Public Access Block"这种需要看多个资源关系才能判断的规则）。
- **False positive vs 已知风险（baseline/skip）**：安全扫描工具不理解"这是学习环境、这个决定是故意的"，所以会把很多合理的设计决定也报成"问题"。用 `.checkov.yaml` 的 `skip-check` 列表把这些逐条列出并写清楚理由，是比"直接忽略报错"更负责任的做法——理由本身就是留给未来自己（或面试官）看的文档。
- **工具版本没锁 = 结果不可复现**：本地装的 `checkov` 是 3.3.0，CI 里 `pip install checkov` 没写版本号，装到了最新的 3.3.8，多出一整批 graph check（`CKV2_AWS_*`），导致本地"全绿"但 CI 报了 41 个新问题。教训和 tflint 的 `required_version` 完全同源——**任何会影响输出结果的工具，都该固定版本**，不只是 Terraform provider。修法：CI 里 `pip install checkov==3.3.8` 写死版本，本地也升级到同一个版本对齐。
- **`aws_default_security_group`**：每个 VPC 创建时 AWS 会自动带一个"default" security group，如果不管它，任何没指定 SG 的资源可能意外挂到它上面、继承一份没审查过的规则。最佳实践是用这个 resource 接管它、清空成没有任何 ingress/egress 规则。
- **S3 Public Access Block**：`aws_s3_bucket_public_access_block` 是挂在 bucket 上的一层"总闸"，四个开关全部设 `true` 就能保证哪怕 bucket policy 或 ACL 不小心配错，也没法把 bucket 变成公开访问——是免费、几乎没有理由不加的兜底防护。
- **ECS vs EKS**：两条完全独立的技术路线，不是同一个东西的两种形态。ECS 是 AWS 自研的编排系统，有自己的一套 API（`aws ecs` 命令），跟 Kubernetes 没有血缘关系；EKS 是 AWS **托管的、真正的 Kubernetes**（控制平面是标准 K8s 组件，AWS 只负责运维），用的还是标准 `kubectl`。类比：**EKS 之于 Kubernetes，就像 RDS 之于 MySQL**——都是"云厂商托管开源标准"，不是"云厂商自己发明的替代品"（ECS 才是那个替代品）。
- **Fargate 是计算层，ECS/EKS 是编排层**：两者是正交的选择——Fargate（serverless 跑容器）不是 ECS 独有的，EKS 也有 Fargate profile，可以不管理 EC2 node 就跑 pod。
- **Task ≈ Pod，Task Definition ≈ Pod spec，ECS Service ≈ Deployment**：K8s 概念在 ECS 里的对应关系。但不是处处都有对应物——**StatefulSet**（稳定网络身份+专属存储）、**DaemonSet**（每节点一个 pod，Fargate 下概念不成立）、**PV/PVC/StorageClass**（声明式存储抽象）ECS 都没有对等物；**K8s 的 Service**（负载均衡+DNS）跟 **ECS 的 Service**（维持副本数）是完全不同的两个东西，是最容易踩的命名坑，ECS 里真正对应 K8s Service 功能的是 Cloud Map（服务发现）+ ALB（负载均衡）两个独立组件拼起来的。
- **Task execution role vs Task role**：execution role 给 ECS agent 自己用（拉镜像、写 CloudWatch 日志）；task role 给容器内应用代码用（调用 AWS API），这次 nginx demo 没用到后者。
- **`awsvpc` network mode**：Fargate 强制使用，每个 task 有独立的 ENI + 私有 IP，行为上更接近一台迷你 EC2，而不是传统 Docker 那种共享宿主机网络。
- **ECS task 的 public IP 无法 output**：`aws_ecs_service` 这个 resource 不追踪"当前具体是哪个 task、用了哪个 IP"——task 是 ECS 运行时动态调度的，不是 Terraform 直接管理的 resource，所以连 `known after apply` 都算不上。生产环境的正解是**接 ALB**，永远不直接依赖 task IP（ALB 自己的 DNS name 才是可以稳定 output 的东西）；Phase 11 这次因为故意跳过了 ALB，用 AWS CLI（`list-tasks` → `describe-tasks` 拿 ENI ID → `describe-network-interfaces` 查 public IP）手动验证。
- **`aws_eks_access_entry` / access policy**：2023 年后 EKS 新增的集群访问管理机制，取代了老式手动改 `aws-auth` configmap 的方式，直接用 IAM 身份（`aws_caller_identity`）加一条 access entry + 关联一个 access policy（如 `AmazonEKSClusterAdminPolicy`）就能让 `kubectl` 认证通过。这类 AWS 专属服务的 ARN 格式要留意"两个连续冒号"的写法（如 `arn:aws:eks::aws:cluster-access-policy/...`），跟 IAM managed policy 的 ARN 格式（`arn:aws:iam::aws:policy/...`）是同一个套路——中间空的 region 段。
- **EKS subnet 也要求横跨至少 2 个 AZ**：跟 Phase 7 踩过的 RDS subnet group 是同一条规则。
- **EKS 控制平面没有 node 时**：`kubectl get svc` 依然能看到默认的 `kubernetes` service（用来验证 API server 连通性，不需要任何 node）；但 EKS 自动装的 **CoreDNS** add-on 的 pod 会卡在 `Pending`，因为 scheduler 找不到 node 可以调度——很直观地印证了"控制平面本身不等于有地方跑东西"。
- **SG-to-SG 引用 vs CIDR/IP 引用**：Security Group 的 ingress 规则可以用 `security_groups = [...]` 直接引用另一个 SG 的 ID 当 source，而不是写死 CIDR——这是生产环境限制"只有 app tier 能访问 DB"的标准做法，比 `my_ip` 那种基于 IP 的访问控制更本质，因为它绑定的是"身份"（哪个资源）而不是"位置"（哪个 IP）。`modules/rds` 为此加了两个 `dynamic "ingress"` block，分别处理 `my_ip`（可选，`default = null`）和 `allowed_security_group_ids`（新加），两者互不冲突，向后兼容 Phase 5/7 的旧调用方式。
- **ALB target group 的 `target_type = "ip"`**：Fargate task 走 `awsvpc` 模式，每个 task 是独立 IP 身份、不是 EC2 实例，所以 target group 必须用 `ip` 类型注册目标，不能用默认的 `instance` 类型。
- **ECS Service 的 `load_balancer` block 三个隐藏依赖**：`container_name` 必须跟 task definition 里容器的 `name` 完全一致（否则注册失败）；target group 必须先挂到一个 `aws_lb_listener` 上，ECS Service 才能成功注册进去，这跟 Phase 6 的 `aws_s3_bucket_notification` 等 `aws_lambda_permission` 是同一类"AWS API 层面强制顺序、Terraform 推不出隐式依赖"的情况，要手动加 `depends_on`。
- **ECS Task Definition 的"replace"是版本化，不是真删除**：任何改动（比如新加 `task_role_arn`）都会让 Terraform 显示 "must be replaced"，本质是 ECS 给这个 family 生成了一个新的不可变 revision，旧 revision 会被 deregister 但不会真的从 AWS 上消失——这是 ECS 任务定义天生的版本化机制，不是需要担心的破坏性操作。
- **ECS Exec / `execute-command`**：需要三样东西同时具备才能用——service 上 `enable_execute_command = true`、task 挂一个带 SSM Messages 权限（`ssmmessages:Create/OpenControlChannel`、`ssmmessages:Create/OpenDataChannel`，这几个 action 官方规定只能用 `resources = ["*"]`，没有更细粒度的写法）的 **task role**（不是 execution role）、本地装 AWS 官方的 **Session Manager Plugin** 二进制（`brew install --cask session-manager-plugin`，是 AWS CLI 之外单独的依赖）。改 task definition 触发新 revision 后，ECS 会做滚动更新，短暂出现 `desired_count` 两倍的 task 数量（新旧并存），等新的通过 health check 才会把旧的下线，是正常过渡状态。
- **验证纯 TCP 连通性不需要装数据库客户端**：容器里没有 `mysql`/`psql` 这类客户端时，可以用 bash 自带的 `/dev/tcp` 伪设备做最轻量的连通性测试：`bash -c 'echo > /dev/tcp/<host>/<port> && echo OPEN || echo CLOSED'`——只验证 TCP 三次握手成功与否（也就是 security group 允不允许），不做真正的协议层握手，比装一个客户端再连接更快、更聚焦。
- **迁移非空 state 到 remote backend**：跟 Phase 1 那次"从空 state 开始"不同，给一个已经有 20+ 真实资源的 root module 加 `backend` block 后跑 `terraform init`，Terraform 会主动问"是否要把现有 state 复制到新 backend"，必须选 `yes`——选 `no` 会让 Terraform"忘记"所有已存在的资源，导致下次 apply 试图重新创建已经在运行的东西。`backend` block 本身的生效方式是 `terraform init`，不是 `terraform apply`（不对应任何 AWS resource，纯 Terraform CLI 自身的行为配置）。
- **CI role 权限：`ci_permissions` 精确授权 vs `ReadOnlyAccess` 广泛只读**：Phase 9 的 CI 因为从没真正 apply 过，plan 面对的是空 state，可以精确到"就给这一个 bucket 的几个 action"；Capstone 的 CI 要对着 20+ 个真实资源跑 `plan`，`plan` 本身需要跨多个服务 `Describe`/`Get`/`List`，逐条精确授权不现实，改用 AWS 官方托管的 `ReadOnlyAccess`——这是业界对"只读、只 plan、不 apply"型 CI pipeline 的常见务实做法。另外容易漏掉的一点：**state locking 即使在 `plan` 阶段也要写 DynamoDB**（`PutItem`/`DeleteItem` 那条 `LockID` 记录），`ReadOnlyAccess` 明确排除所有写类 action，所以要单独给 lock table 补一条包含 `dynamodb:PutItem`/`GetItem`/`DeleteItem` 的权限。
- **checkov 对"两个值是否不同"的静态分析局限**：`CKV_AWS_249`（execution role 和 task role 必须不同）在这次 Capstone 报了 false positive——两个角色其实是两个完全独立的 module 调用，代码层面确定不同，但两边的 `role_arn` 在 `terraform plan` 阶段都只是 `(known after apply)`，checkov 拿不到真实值，没法在静态分析阶段证明"这两个值不相等"，只能保守地判定为失败——这是纯静态扫描工具的天然局限，不是代码问题。

## 当前进度 (Current Progress)

- **2026-07-06**：Phase 0 基本完成。Terraform CLI 已安装（v1.14.8）。完成了 `local_file` 资源的 init/plan/apply/destroy 练习、variable/output 改造、`-var` 覆盖 default 练习，并理解了 replace（强制重建）vs update（原地更新）的区别。
- **2026-07-06**：Phase 1（远程 backend）完成。用 bootstrap/app 两个 root module 的模式创建了 S3 + DynamoDB backend，验证了 state 确实存到了 S3 上（本地不再有 tfstate 文件），并完整走了一遍销毁流程（含 `force_destroy` 处理 versioning 导致的非空 bucket 问题）。
- **2026-07-07**：Phase 2（网络）完成，含两个扩展实验。搭建了含 public/private subnet 的最小 VPC 拓扑（VPC + IGW + 2 subnet + route table + security group），验证了 private subnet 因为缺少 public IP + IGW route 而双向隔离；做了 NACL 对比练习（stateful vs stateless，踩了 protocol number 的坑）；短时验证了 NAT Gateway（EIP + NAT GW + private route table 指向 NAT），确认 route 生效后立刻 destroy，12 个资源全部清理干净且验证无残留（含最容易漏删的 Elastic IP）。
- **2026-07-07**：Phase 3（计算 EC2）完成，含两个扩展实验。用 default VPC + data source 动态查 AMI + `user_data` 起了一台 EC2，装 nginx 并通过 curl 验证；加了 key pair 做 SSH 验证（体验了一次 `key_name` 触发的 ForceNew replace）；做了 IMDSv2 hardening（体验了属性可以原地更新 vs 强制重建的对比）；用 AWS CLI 做了 stop/start，验证了动态 public IP 会变、但磁盘数据持久化。全部资源 + 本地 SSH key 已清理干净。
- **2026-07-07**：Phase 4（IAM 与安全）完成。搭了一个 EC2→S3 只读的最小权限 role（instance profile 模式），用 `aws iam simulate-principal-policy` 验证了 least privilege 边界（允许的 allowed，没提到的 implicitDeny）；搭了 GitHub Actions OIDC role（trust policy 精确锁定到 `repo:ddliuwx/cloud-native-lab`，permission 故意先给到最小，等 Phase 9 真正需要时再加）；顺手做了一次 local name 重命名的重构练习，学会了用 `terraform state mv` 避免不必要的 destroy+create。全部 8 个 IAM 资源已清理并校验干净。KMS/aws-vault 探索和腾讯云 CAM 对照练习待定。
- **2026-07-07**：Phase 5（存储与数据库）完成。Part A 建了带 versioning/encryption/lifecycle rule 的 S3 bucket；Part B 建了一个单 AZ `db.t3.micro` MySQL RDS，用 `manage_master_user_password` 让 AWS 托管密码、通过 Secrets Manager 取用并成功连接验证；额外探索了自动备份默认值陷阱（`backup_retention_period` 默认 0）和 `apply_immediately` 概念（改动排队 vs 立即生效）。全部资源+ RDS 自动生成的 secret 已清理并校验干净。腾讯云 COS/TencentDB 对照练习待定。
- **2026-07-08**：Phase 6（无服务器）完成，含一个扩展实验。Step 6.1 搭了一个 Lambda 函数（Python），用 `aws lambda invoke` 独立验证；Step 6.2 接上 API Gateway HTTP API，验证了同步的请求-响应式触发（curl 直接拿到 Lambda 返回值）；扩展实验做了 S3 event trigger，验证了异步事件驱动触发（上传文件自动触发 Lambda，CloudWatch Logs 里看到了完整的 cold start 过程）。踩了两个坑：`archive_file` 的 `source_dir`/`source_file` 混用报错、`aws_s3_bucket_notification` 需要显式 `depends_on` 等 `aws_lambda_permission` 先创建好。全部资源已清理并校验干净（含一次 `force_destroy` 处理非空 bucket 的重复坑）。腾讯云 SCF 对照练习待定。额外给 Phase 1-6 都补充了资源依赖图/流量图（存在各自目录下的 `diagrams/` 里）。
- **2026-07-09**：Phase 7（模块化）完成，超出原计划，把 IAM/S3/RDS/Lambda 全部也做成了 module。建了 5 个 module：`modules/vpc`（故意不含 SG/NAT）、`modules/ec2`、`modules/iam-role`（用 `for_each`/`count`/`try()` 支持灵活 attach policy + 可选 instance profile，同一个 module 成功复用在 EC2 assume role 和 GitHub OIDC 两种差异很大的 trust policy 场景）、`modules/s3-bucket`、`modules/lambda`，加上 `modules/rds`。在 `phase7-modules` 这个 root module 里组合调用，验证了三层 module 组合（root → iam-role → lambda，`role_arn` 跨两层传递）。踩了两个新坑：`for_each` 用 `toset()` 时元素引用未创建资源的属性会报错（改用 map + 静态 key 解决）、RDS subnet group 必须跨至少 2 个 AZ（且要用 public subnet 才能让 `publicly_accessible` 真正生效）。全部 28 个资源已清理并校验干净。
- **2026-07-09**：Phase 8（多环境管理）完成。用 `modules/s3-bucket` 当练习对象，对比了 workspace（同代码切 state，靠 `terraform.workspace` 变量区分，本地 state 存在 `terraform.tfstate.d/` 下，风险是切错环境不易察觉）和目录分层（`envs/dev`、`envs/prod` 各自独立 root module，靠物理目录隔离，能指向不同 backend/账号）两种模式，验证了两边各自的 state 隔离行为。全部 4 组 bucket（12 个资源）+ 2 个 workspace 已清理并校验干净。下一步：Phase 9（CI/CD 集成，用 Phase 4 已建好的 GitHub OIDC role）；腾讯云对照练习全线待定。
- **2026-07-10**：Phase 9（CI/CD 集成）完成。`phase9-cicd/iam-bootstrap` 重新部署了 GitHub OIDC provider + role（trust policy 精确锁定 `repo:ddliuwx/cloud-native-lab` 的 `main` 分支 push 和所有 PR），这次**刻意长期保留、不 destroy**；`phase9-cicd/ci-demo` 建了一个小巧的 `modules/s3-bucket` 调用当 CI 的 plan 目标；`.github/workflows/terraform-plan.yml` 用 `aws-actions/configure-aws-credentials` 的 OIDC 免密登录，跑 `fmt/validate/plan` 并把 plan 结果自动评论回 PR。真实走了一遍 PR 流程（`phase9-cicd` 分支 → PR → 三项 check 全绿 → merge 到 `main`），期间连续踩了三个坑：module 里 `version`/`versioning` 打错撞上 Terraform 保留字段、变量名想当然写成 `versioning` 而实际是 `enable_versioning`、output 引用了 module 里不存在的 `bucket_name`（应为 `bucket_id`）——每个都是靠读真实报错逐步定位修复的。全程验证了 OIDC 认证本身第一次就成功（回执里 "Configure AWS credentials via OIDC" 一直是绿的），说明 Phase 4 打下的 IAM 基础是对的。此后确立新约定：**之后所有改动都走 PR**（Claude 建分支/commit/push/开 PR，学习者手动 review + merge）。
- **2026-07-10**：Phase 10（测试与安全扫描）完成。装了 `tflint`（走官方 install script，绕开了本地 Homebrew tap 的匿名 HTTPS clone 网络问题）和 `checkov`。第一轮 `tflint --recursive` 在 Phase 0-9 全仓库扫出 27 个真实问题（缺 `required_version`/`required_providers`），全部修复，顺手补回了 `modules/ec2` 在 Phase 7 重构时弄丢的 IMDSv2 hardening。第二轮 `checkov` 扫出 60 个 FAILED，分成"免费真修"（EBS/RDS 加密、`auto_minor_version_upgrade`、S3 lifecycle 补全、SG description）和"刻意设计决定"（单 AZ、`publicly_accessible=true`、Lambda 不进 VPC 等，写进 `.checkov.yaml` 的 `skip-check` 并逐条注明理由）两类。CI 里新增 `.github/workflows/terraform-lint-security.yml`，`terraform/**` 有改动就跑 tflint + checkov。PR 里第一次跑 CI 时因为没锁 checkov 版本，装到了比本地更新的版本、多出一整批 graph check（`CKV2_AWS_*`），又暴露了 41 个新问题（default SG 没清空、S3 缺 Public Access Block、RDS 缺 `copy_tags_to_snapshot`、两个 bucket 完全没有 lifecycle/versioning），修复后把 checkov 版本锁定为 `3.3.8`（本地和 CI 保持一致）。全程走 PR 流程验证，两轮修复分两次 push 到同一个 PR，最终 CI 全绿、手动 merge。
- **2026-07-11**：Phase 11（容器编排）完成，含 EKS 扩展验证。`phase11-containers` 用 `modules/vpc` 建了 ECS Fargate 服务：ECS Cluster + Task Definition（Docker Hub 公共 `nginx` 镜像，不用自己 build/push）+ execution role（复用 `modules/iam-role`）+ Service（`awsvpc` network mode，`assign_public_ip = true`）+ SG，故意跳过 ALB 保持这次专注在 ECS/Fargate 概念本身。验证时发现 `aws_ecs_service` 拿不到 task 的 public IP（task 是运行时动态调度的，不是 Terraform 管理的 resource），改用 AWS CLI 三连（`list-tasks` → `describe-tasks` 拿 ENI → `describe-network-interfaces` 查 IP）手动查到 IP 后 curl 验证成功。扩展做了 EKS 短时验证：只建控制平面不建 node group（省掉 EC2 费用），用新的 `aws_eks_access_entry`/`aws_eks_access_policy_association` 机制（而不是老式 `aws-auth` configmap）授权 kubectl，`update-kubeconfig` 后验证 `kubectl get svc` 能看到默认 service（确认 API 连通），`kubectl get -A pods` 看到 CoreDNS 因为没有 node 卡在 Pending（符合预期）。踩了两个坑：EKS cluster-access-policy 的 ARN 少写了一段（`eks::aws:` 中间要两个冒号）、EKS subnet 同样要求横跨至少 2 个 AZ（和 RDS subnet group 同一条规则）。ECS + EKS 全部 21 个资源验证销毁干净。腾讯云 TKE 对照练习待定。
- **2026-07-12**：**毕业项目 (Capstone) 完成**，学习计划主线 Phase 0-11 全部结束。`capstone/` 用 Terraform 搭了一套真正的三层架构：ALB（public subnet，两个 AZ）→ ECS Fargate（**private subnet**，无 public IP，跟 Phase 11 故意做的简化版不同）→ RDS（**private subnet**，`publicly_accessible=false`，跟 Phase 5/7 那种"图方便直连测试"的版本也不同）。为此把 `modules/vpc` 加了第二个 private subnet（跟 Phase 7 加 `public_b` 同一个模式），把 `modules/rds` 用两个 `dynamic "ingress"` block 扩展出 SG-to-SG 访问控制（`allowed_security_group_ids`），向后兼容 Phase 5/7 的 `my_ip` 用法。选型上特意讨论过"app tier 放 public+限制性 SG" vs "private+NAT" vs "private+VPC Endpoint"三条路，选了教科书式的 private subnet + NAT Gateway。踩了三个真实 bug：`modules/vpc` 只加了一半的 route table association（`private_b` 漏了）、ECS Service 的 `network_configuration.subnets` 手滑写成了 public subnet id（推翻了整个"私有 app tier"的设计意图）、`module.execution_role.arn` 应为 `.role_arn`（Phase 9 同款错误又犯一次）。端到端验证分两层：curl ALB DNS name 拿到 nginx 页面（证明 User→ALB→ECS 链路通）；额外扩展了 ECS Exec 验证（新增 task role + `enable_execute_command`，本地装 Session Manager Plugin），进容器用 `/dev/tcp` 测 RDS 3306 端口连通性，`OPEN`（证明 ECS→RDS 链路通，SG-to-SG 规则生效）。Remote state 部分踩了个大坑：Phase 1 的 backend bucket/table 早就被销毁了，不能直接复用，靠重新 `apply` 一次 `phase1-backend/bootstrap`（换新 `unique_suffix`）建了专属的新 backend，再给已经有 20+ 真实资源的 root module 加 `backend` block、`terraform init` 触发 state 迁移（选 `yes` copy，不是从空开始）。CI/CD 把 GitHub OIDC role 的权限从 Phase 9 的"精确到一个 bucket"扩成了 `ReadOnlyAccess`（因为这次 plan 面对的是真实的多服务资源，逐条精确授权不现实），另外单独补了 DynamoDB lock table 的读写权限（`ReadOnlyAccess` 不含任何写 action，但 state locking 本质要写一条 `LockID`）。checkov 在这次也报了一个 false positive（`CKV_AWS_249`，两个 role 其实不同，但两边 ARN 在 plan 阶段都是 `known after apply`，工具没法静态证明"不相等"）。全程走 PR 流程，`Capstone Terraform Plan` 这条新 CI 第一次面对真实、非空 state 跑 `plan` 就成功。
