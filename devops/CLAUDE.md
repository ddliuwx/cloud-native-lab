# DevOps 学习计划 (DevOps Learning Plan)

## 项目背景 (Background)

这个目录用于系统性练习 DevOps 相关技能，目标同样是新西兰（New Zealand）DevOps/Cloud Engineer 岗位的招聘要求。跟 `terraform/CLAUDE.md` 里的 IaC (Infrastructure as Code) 学习计划是姊妹关系——那边专注 Terraform 本身，这里往外扩展到 CI/CD、容器化 (containerization)、编排 (orchestration)、可观测性 (observability) 等更完整的 DevOps toolchain。

Phase 排序按新西兰真实 job posting 的出现频率 + 技能依赖关系确定（细节见下面"岗位要求调研"一节），不是按证书大纲或教材目录排的。

## 协作约定 (Collaboration Conventions)

沿用 `terraform/CLAUDE.md` 里的基本约定（命令行本人执行、代码示例逐步从"完整示例"过渡到"骨架+填空"、及时校验/清理资源、命名规范、fmt/lint 先行、全部改动走 PR），额外补充：

1. **双语风格加强 (increased bilingual density)**：从本文件开始，回答中会尽量多用英文单词/短语（比之前的比例更高），中文仍然是句子的主干结构，保证你读得懂，但技术词汇、动词短语会更倾向直接用英文。每条消息中英文词汇/短语第一次出现时标注 IPA。
2. **每个 Phase 自带词汇表 + 句型 (vocabulary & sentence patterns)**：不只是"这个词是什么意思"，还会给日常 DevOps 工作场景里的实用句型（standup、PR description、incident report、code review comment 等），因为这是你在真实岗位里会用到英语的地方。
3. **Go 代码同样以提示为主**：跟 Terraform 一样，基础语法阶段给完整示例，进阶阶段更多给"骨架 + 需要你填的部分"。

## 新西兰 DevOps 岗位要求调研 (NZ Job Requirement Research)

基于 SEEK / Indeed / Glassdoor 上的 DevOps Engineer / Senior DevOps Engineer posting，以及一个 Christchurch 真实岗位（明确要求 "AWS in production including multi-region setups, IAM, and networking" + "production observability and monitoring stack with SLO definition and alerting"）：

| 优先级 | 技能/工具 | 出现频率 |
|---|---|---|
| 最高 | CI/CD pipeline（GitHub Actions / GitLab CI / Jenkins / ArgoCD） | 几乎所有 posting |
| 最高 | Terraform、AWS | IaC 与云平台的标准组合 |
| 高 | Docker、Kubernetes（部分提 OpenShift）、**Helm** | mid-senior 岗位 baseline requirement，Helm 常与 K8s 绑定出现 |
| 中高 | Observability（CloudWatch、Datadog、Prometheus/Grafana，SLO/SLI/alerting） | 真实 NZ posting 明确写出 |
| 中高 | GitOps 模式（工具不挑，ArgoCD/Flux 皆可） | K8s 生态的部署方式，重要的是模式而非特定工具 |
| 中 | Python/PowerShell（Go 出现率较低，但 K8s/Terraform/Docker 生态本身用 Go 写） | automation scripting |
| 中 | Ansible / AWS CloudFormation | configuration management，常与 Terraform 并列 |
| 提及 | Security & compliance（least privilege、secrets management、NZISM、GuardDuty/Security Hub/WAF） | senior 岗位更强调 |
| 提及 | Azure（部分企业/政府岗位） | 次要云平台 |
| 提及 | Agile/Scrum 协作 | 软技能，几乎所有 posting 的"协作方式"一栏都提 |

## 学习路线图 (Roadmap)

### Phase 1 — CI/CD Pipeline（GitHub Actions）
**对应要求**：几乎所有 posting 的硬性要求。

**内容**：
- Workflow /ˈwɜːkfloʊ/ 文件结构（`on`、`jobs`、`steps`）、trigger 类型（push、pull_request、schedule、workflow_dispatch）
- Matrix build（多版本/多平台并行）、reusable workflow（`workflow_call`）、composite action
- Secrets & environment protection rule（deployment approval gate）
- GitHub Actions OIDC 对接 AWS IAM role（无长期 access key）
- GitHub-hosted vs self-hosted runner 的取舍
- Artifact 传递、dependency cache

**实践**：给 terraform 目录做一条完整 pipeline——PR 触发 `terraform plan`（OIDC 认证），merge 后走 approval gate 再 `apply`。

**词汇与句型 (Vocabulary & Sentence Patterns)**：

| English | IPA | 中文 |
|---|---|---|
| pipeline | /ˈpaɪplaɪn/ | 流水线 |
| workflow | /ˈwɜːkfloʊ/ | 工作流 |
| trigger | /ˈtrɪɡər/ | 触发 |
| job | /dʒɒb/ | 任务（workflow 里的一个执行单元） |
| step | /step/ | 步骤 |
| runner | /ˈrʌnər/ | 执行器 |
| artifact | /ˈɑːrtɪfækt/ | 构建产物 |
| matrix build | /ˈmeɪtrɪks bɪld/ | 矩阵构建 |
| reusable workflow | /riːˈjuːzəbl ˈwɜːkfloʊ/ | 可复用工作流 |
| approval gate | /əˈpruːvl ɡeɪt/ | 审批关卡 |
| self-hosted runner | /self ˈhoʊstɪd ˈrʌnər/ | 自托管执行器 |
| cache | /kæʃ/ | 缓存 |
| rollback | /ˈroʊlbæk/ | 回滚 |

句型：
- "This PR triggers a new workflow run on push to main." 这个 PR 会在 push 到 main 时 trigger 一次新的 workflow run。
- "The pipeline failed at the build step due to a dependency conflict." Pipeline 在 build step 失败了，因为 dependency conflict。
- "We need to add a manual approval gate before the deploy job." 我们需要在 deploy job 前加一个 manual approval gate。
- "Can you re-run the failed job?" 你能 re-run 一下失败的 job 吗？

---

### Phase 2 — Terraform 深化
**对应要求**：IaC 首选工具，招聘要求生产级深度（state management、modules、team review workflow）。

**内容**：承接 `terraform/CLAUDE.md` 里已有的进度（Phase 0-11 + Capstone），本阶段不重复讲基础语法，重点是把已学内容跟 job posting 的实际考察方式对齐——模拟团队协作场景下的 review/审批流程。术语表已经在 `terraform/CLAUDE.md` 的 Glossary 里持续维护，本文件不重复。

**词汇与句型**：

| English | IPA | 中文 |
|---|---|---|
| provisioning | /prəˈvɪʒənɪŋ/ | 资源配置/开通 |
| drift | /drɪft/ | 漂移（实际状态与配置不一致） |
| idempotent | /ˌaɪdəmˈpoʊtənt/ | 幂等的 |

句型：
- "Terraform plan shows 3 resources will be destroyed and recreated." Terraform plan 显示有 3 个资源会被 destroy 并 recreate。
- "We should review the plan output before merging." 我们应该在 merge 前 review 一下 plan 的输出。

---

### Phase 3 — AWS Cloud 专题
**对应要求**：出现频率最高的云平台，NZ posting 明确要求 multi-region、IAM、networking 的生产级理解。

**内容**：
- Compute & Networking：EC2、VPC（子网划分、路由）、Security Group、multi-region 部署概念
- **混合云连接 (hybrid connectivity)**：VPN、Direct Connect——把 on-premises（本地机房）网络接到 AWS 的两种方式，VPN 走公网加密隧道成本低，Direct Connect 是专线更稳定但更贵，招聘里的"networking"要求经常暗含这块
- IAM 深化：role、policy、least privilege，跟 Phase 1 的 OIDC 联动
- 容器/无服务器 workload：ECS/EKS、Lambda、Fargate
- **ECR (Elastic Container Registry)**：AWS 自己的镜像仓库，跟 Phase 4 Docker 的 registry 概念打通，实践时把 Phase 4 build 出来的 image push 到这里
- 存储与数据库：S3、RDS/Aurora
- Observability 初步接触：CloudWatch、X-Ray（Phase 7 深挖）
- **CloudFormation 对照**：AWS 原生的 IaC 工具，跟 Terraform 做同一件事但只能管 AWS（不 provider-agnostic）；部分 posting 会同时提两者，了解语法差异即可，不需要深入练习——重点还是 Terraform

**实践**：VPC 里跑一个 ECS service，Lambda 处理异步任务，CloudWatch 配置告警，image 走 ECR 而不是 Docker Hub——直接对着高频服务组合练手，而不是照抄考证大纲。

**词汇与句型**：

| English | IPA | 中文 |
|---|---|---|
| availability zone | /əˌveɪləˈbɪləti zoʊn/ | 可用区 |
| multi-region | /ˌmʌlti ˈriːdʒən/ | 多区域 |
| fault tolerance | /fɔːlt ˈtɒlərəns/ | 容错 |
| high availability (HA) | /haɪ əˌveɪləˈbɪləti/ | 高可用 |
| scaling | /ˈskeɪlɪŋ/ | 扩缩容 |
| throttling | /ˈθrɒtəlɪŋ/ | 限流 |
| latency | /ˈleɪtənsi/ | 延迟 |
| serverless | /ˈsɜːrvərləs/ | 无服务器 |
| managed service | /ˈmænɪdʒd ˈsɜːrvɪs/ | 托管服务 |
| traffic spike | /ˈtræfɪk spaɪk/ | 流量高峰 |
| on-premises (on-prem) | /ɒn ˈpremɪsɪz/ | 本地机房/自建机房 |
| hybrid connectivity | /ˈhaɪbrɪd kəˌnekˈtɪvəti/ | 混合云连接 |
| dedicated line | /ˈdedɪkeɪtɪd laɪn/ | 专线 |

句型：
- "We connect to the on-prem data center over a site-to-site VPN." 我们通过 site-to-site VPN 连接到 on-prem 数据中心。
- "Can you push this image to ECR before the deploy?" 你能在 deploy 之前把这个 image push 到 ECR 吗？

句型：
- "This service is deployed across two availability zones for high availability." 这个服务跨两个 availability zone 部署，为了 high availability。
- "We're seeing increased latency on the API Gateway." API Gateway 上出现了 latency 增加。
- "Can we scale up the ECS service to handle the traffic spike?" 我们能不能把 ECS service scale up 来应对 traffic spike？

---

### Phase 4 — Containerization（Docker）
**对应要求**：baseline requirement，K8s 的前置知识。

**内容**：image、container、Dockerfile、layer caching、multi-stage build、registry、tag、volume、entrypoint。

**实践**：把一个小工具容器化，推到 ECR/Docker Hub。

**词汇与句型**：

| English | IPA | 中文 |
|---|---|---|
| image | /ˈɪmɪdʒ/ | 镜像 |
| container | /kənˈteɪnər/ | 容器 |
| layer | /ˈleɪər/ | 层 |
| build context | /bɪld ˈkɒntekst/ | 构建上下文 |
| multi-stage build | /ˌmʌlti steɪdʒ bɪld/ | 多阶段构建 |
| registry | /ˈredʒɪstri/ | 镜像仓库 |
| tag | /tæɡ/ | 标签 |
| volume | /ˈvɒljuːm/ | 数据卷 |
| entrypoint | /ˈentripɔɪnt/ | 入口点 |

句型：
- "Can you push the updated image to the registry?" 你能把更新后的 image push 到 registry 吗？
- "This container keeps crashing on startup." 这个 container 一启动就 crash。
- "We should use a multi-stage build to reduce image size." 我们应该用 multi-stage build 来减小 image 体积。

---

### Phase 5 — Orchestration（Kubernetes）
**对应要求**：baseline requirement，紧跟 Docker。

**内容**：pod、deployment、service、ingress、configmap/secret、namespace、replica、rolling update、readiness/liveness probe、CRD、controller、reconcile loop。
- **Helm**：K8s 的包管理器 (package manager)——chart 是打包好的应用模板，release 是 chart 部署出来的一个实例，values.yaml 用来覆盖默认配置。招聘 JD 里"Kubernetes"后面经常直接跟着"Helm"，两者被当成一个组合技能看待
- **GitOps 概念**（不绑定具体工具）：Git 仓库作为集群期望状态的唯一 source of truth，有一个 agent（常见的如 ArgoCD/Flux）持续监听 Git 变化并自动同步到集群。业内对"必须会 ArgoCD"这种要求反而有点警惕（工具可替换），真正要理解的是这个 declarative + 自动同步的模式本身

**实践**：把 Phase 4 的容器部署到本地 minikube/kind；用 Helm 打包这个部署（写一个最简单的 chart）；用 Go 写一个最简单的 custom controller（watch 一个 CRD，做点简单响应），为 Phase 6 打基础。

**词汇与句型**：

| English | IPA | 中文 |
|---|---|---|
| pod | /pɒd/ | pod（K8s 最小调度单元） |
| deployment | /dɪˈplɔɪmənt/ | 部署 |
| ingress | /ˈɪnɡres/ | 入口路由 |
| namespace | /ˈneɪmspeɪs/ | 命名空间 |
| replica | /ˈreplɪkə/ | 副本 |
| rolling update | /ˈroʊlɪŋ ˈʌpdeɪt/ | 滚动更新 |
| readiness probe | /ˈredinəs proʊb/ | 就绪探针 |
| liveness probe | /ˈlaɪvnəs proʊb/ | 存活探针 |
| custom resource definition (CRD) | /ˈkʌstəm rɪˈsɔːrs ˌdefɪˈnɪʃn/ | 自定义资源定义 |
| controller | /kənˈtroʊlər/ | 控制器 |
| reconcile loop | /ˈrekənsaɪl luːp/ | 调和循环 |
| Helm chart | /helm tʃɑːrt/ | Helm 应用打包模板 |
| release | /rɪˈliːs/ | （Helm）部署出来的一个实例 |
| GitOps | /ˈɡɪt ɒps/ | 以 Git 为唯一事实来源的运维模式 |
| source of truth | /sɔːrs əv truːθ/ | 事实来源 |
| declarative | /dɪˈklærətɪv/ | 声明式的 |
| drift detection | /drɪft dɪˈtekʃn/ | 漂移检测 |

句型：
- "The pod is stuck in CrashLoopBackOff." 这个 pod 卡在 CrashLoopBackOff 状态。
- "We need to bump the replica count to handle more load." 我们需要把 replica count 调高来应对更多负载。
- "The readiness probe is failing, so the pod isn't receiving traffic." Readiness probe 失败了，所以这个 pod 收不到流量。
- "Can you package this as a Helm chart?" 你能把这个打包成一个 Helm chart 吗？
- "ArgoCD detected drift and auto-synced the cluster back to the desired state." ArgoCD 检测到 drift，自动把集群 sync 回了期望状态。

---

### Phase 6 — Automation Scripting（Golang）
**对应要求**：中频技能词，但 Go 是 cloud-native 工具链的"母语"（Docker/K8s/Terraform/Prometheus 都用 Go 写），能读懂并写 controller/operator 是深度证明。

**内容**：
- Go 基础语法、错误处理、goroutine/channel 基础
- AWS SDK for Go：写脚本替代手动操作（批量打 tag、清理闲置资源）
- 用 Cobra 之类的库写一个小型 CLI 工具，跟 Phase 5 的 K8s controller 呼应

**词汇与句型**：

| English | IPA | 中文 |
|---|---|---|
| goroutine | /ˈɡoʊruːtiːn/ | Go 的轻量级协程 |
| channel | /ˈtʃænl/ | 通道（goroutine 间通信） |
| struct | /strʌkt/ | 结构体 |
| interface | /ˈɪntərfeɪs/ | 接口 |
| error handling | /ˈerər ˈhændlɪŋ/ | 错误处理 |
| package | /ˈpækɪdʒ/ | 包 |
| compile | /kəmˈpaɪl/ | 编译 |
| concurrency | /kənˈkʌrənsi/ | 并发 |
| CLI (command-line interface) | /siː el aɪ/ | 命令行接口 |
| SDK (software development kit) | /es diː keɪ/ | 软件开发工具包 |

句型：
- "This function returns an error if the AWS call fails." 如果 AWS 调用失败，这个 function 会返回一个 error。
- "We used a goroutine to run this task concurrently." 我们用了一个 goroutine 来并发跑这个任务。
- "Can you write a small CLI tool for this?" 你能写一个小的 CLI tool 来做这个吗？

---

### Phase 7 — Observability
**对应要求**：真实 NZ posting（Christchurch）明确要求 "production observability and monitoring stack with SLO definition and alerting"。

**内容**：Prometheus/Grafana 或 CloudWatch/X-Ray 深挖；metric、log、trace 三大支柱；SLO/SLI/SLA 的区别；alert 设计原则（避免 noisy alert）。
- **Datadog**：常见的商业一体化 observability 平台（跟开源的 Prometheus/Grafana 组合是竞品关系），招聘 JD 里出现频率不低，了解它跟自建方案的 trade-off（托管省心 vs 成本更高）即可，不需要单独花时间深入练习

**词汇与句型**：

| English | IPA | 中文 |
|---|---|---|
| observability | /əbˌzɜːrvəˈbɪləti/ | 可观测性 |
| metric | /ˈmetrɪk/ | 指标 |
| trace | /treɪs/ | 追踪 |
| alert | /əˈlɜːrt/ | 告警 |
| dashboard | /ˈdæʃbɔːrd/ | 仪表盘 |
| SLO (service level objective) | /es el oʊ/ | 服务等级目标 |
| SLI (service level indicator) | /es el aɪ/ | 服务等级指标 |
| SLA (service level agreement) | /es el eɪ/ | 服务等级协议 |
| on-call | /ɒn kɔːl/ | 值班 |
| incident | /ˈɪnsɪdənt/ | 事件/故障 |
| root cause | /ruːt kɔːz/ | 根因 |
| managed platform | /ˈmænɪdʒd ˈplætfɔːrm/ | 托管平台（如 Datadog） |
| trade-off | /treɪd ɒf/ | 权衡取舍 |

句型：
- "We got paged at 2am because of a CPU spike." 我们凌晨 2 点因为 CPU spike 被 paged。
- "The root cause was a memory leak in the payment service." Root cause 是 payment service 里的 memory leak。
- "This alert is too noisy, we should tune the threshold." 这个 alert 太 noisy 了，我们应该调一下 threshold。

---

### Phase 8 — Configuration Management（Ansible）
**对应要求**：中高频，常与 Terraform 并列出现，但按你的要求延后学习。

**内容**：playbook、inventory、module、idempotent task、role、handler、ad-hoc command。

**词汇与句型**：

| English | IPA | 中文 |
|---|---|---|
| playbook | /ˈpleɪbʊk/ | 剧本（一组配置任务的集合） |
| inventory | /ˈɪnvəntri/ | 主机清单 |
| idempotent | /ˌaɪdəmˈpoʊtənt/ | 幂等的 |
| handler | /ˈhændlər/ | 事件处理器 |
| ad-hoc command | /æd hɒk kəˈmænd/ | 临时命令 |

句型：
- "This playbook configures nginx across all web servers." 这个 playbook 在所有 web server 上配置 nginx。
- "The task is idempotent, so re-running it is safe." 这个 task 是 idempotent 的，所以重复跑是安全的。

---

### Phase 9 — Security & Governance
**对应要求**：必须掌握，招聘里 senior 岗位强调，但按你的要求延后学习。

**内容**：vulnerability scanning、compliance、encryption at rest/in transit、secrets management、least privilege、audit log。
- **NZISM (New Zealand Information Security Manual)**：新西兰政府信息安全手册，政府相关承包商岗位经常点名要求"熟悉/遵循 NZISM"——不用背全文，重点是理解它属于"合规框架 (compliance framework)"这一类东西，跟 IAM/encryption 这些技术手段是"标准要求什么 vs 我们怎么技术实现"的关系
- **AWS 原生安全服务（跟 Phase 3 的 AWS 专题打通）**：GuardDuty（威胁检测，持续分析 CloudTrail/VPC Flow Logs 找异常行为）、Security Hub（把多个安全工具的发现汇总成一个统一 dashboard）、WAF (Web Application Firewall，挡 SQL injection/XSS 这类应用层攻击，常年挂在 ALB/CloudFront 前面）

**词汇与句型**：

| English | IPA | 中文 |
|---|---|---|
| vulnerability | /ˌvʌlnərəˈbɪləti/ | 漏洞 |
| compliance | /kəmˈplaɪəns/ | 合规 |
| compliance framework | /kəmˈplaɪəns ˈfreɪmwɜːrk/ | 合规框架 |
| encryption at rest | /ɪnˈkrɪpʃn æt rest/ | 静态加密 |
| encryption in transit | /ɪnˈkrɪpʃn ɪn ˈtrænzɪt/ | 传输中加密 |
| secrets management | /ˈsiːkrəts ˈmænɪdʒmənt/ | 密钥管理 |
| audit log | /ˈɔːdɪt lɒɡ/ | 审计日志 |
| CVE (common vulnerabilities and exposures) | /siː viː iː/ | 公共漏洞和暴露编号 |
| patch | /pætʃ/ | 补丁 |
| threat detection | /θret dɪˈtekʃn/ | 威胁检测 |
| anomalous behavior | /əˈnɒmələs bɪˈheɪvjər/ | 异常行为 |
| findings | /ˈfaɪndɪŋz/ | （安全工具报出的）发现项 |

句型：
- "This dependency has a known CVE, we need to patch it." 这个 dependency 有已知的 CVE，我们需要 patch 它。
- "All secrets should be stored in a secrets manager, not in code." 所有 secret 都应该存在 secrets manager 里，而不是写死在代码里。
- "GuardDuty flagged anomalous API activity from an unfamiliar IP." GuardDuty 标记了来自陌生 IP 的 anomalous API activity。
- "We need to make sure this setup aligns with NZISM before it goes to production." 上生产前我们得确认这套配置符合 NZISM 的要求。

---

### Phase 10 — Capstone Project
**对应要求**：整合前面所有 phase，作为求职作品集 (portfolio)。

**内容**：端到端项目——代码提交 → CI 跑测试构建镜像 → CD 部署到 K8s（用 Terraform 管理集群）→ 监控告警接入。至少一个组件（CLI 工具或 K8s controller）用 Go 实现。全英文写 README、architecture diagram、PR description。
- **Agile/Scrum 协作表达**：NZ posting 里"协作方式"一栏几乎总提 Agile/Scrum，DevOps 岗位虽然不是 Scrum Master，但天天要用这套词汇跟开发团队沟通——本阶段专门练一遍 sprint /standup /retro 相关的英文表达，模拟真实团队协作场景，而不只是技术输出

**词汇与句型**：

| English | IPA | 中文 |
|---|---|---|
| end-to-end | /end tuː end/ | 端到端 |
| portfolio | /pɔːrtˈfoʊlioʊ/ | 作品集 |
| architecture diagram | /ˈɑːrkɪtektʃər ˈdaɪəɡræm/ | 架构图 |
| handover | /ˈhændoʊvər/ | 交接 |
| retrospective (retro) | /ˌretrəˈspektɪv/ | 复盘 |
| sprint | /sprɪnt/ | 冲刺（Scrum 的固定周期迭代） |
| standup | /ˈstændʌp/ | 站会 |
| backlog | /ˈbæklɒɡ/ | 待办事项列表 |
| blocker | /ˈblɒkər/ | 阻塞项 |
| story point | /ˈstɔːri pɔɪnt/ | 故事点（估算工作量的单位） |

句型：
- "This project demonstrates end-to-end ownership of the deployment pipeline." 这个项目展示了对整个 deployment pipeline 的端到端 ownership。
- "Let's do a retrospective after the capstone is done." Capstone 完成后我们做一次 retrospective。
- "In today's standup: yesterday I finished the Helm chart, today I'm working on the CI pipeline, no blockers." 今天的 standup：昨天完成了 Helm chart，今天在做 CI pipeline，没有 blocker。
- "This story is 5 points, should we split it before the next sprint?" 这个 story 估了 5 个 point，我们要不要在下个 sprint 前拆一下？

## 当前进度 (Current Progress)

尚未开始，等 Phase 1（CI/CD Pipeline / GitHub Actions）正式启动后在这里追加记录。
