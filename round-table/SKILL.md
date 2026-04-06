---
name: roundtable
description: >-
  一人公司的多 Agent 圆桌决策系统。通过 subagent 实现真正独立的角色人格。
  当用户说"圆桌讨论"、"开个会"、"讨论一下"、"评估可行性"、"行不行"、
  "给我不同角度的意见"、"roundtable"时使用。
  核心机制：为每个角色 spawn 独立的 subagent，各自拥有独立上下文和人格 prompt，
  主 agent 作为主持人编排讨论流程。
---

# RoundTable：多 Subagent 圆桌讨论

每个角色是一个独立的 subagent，拥有自己的上下文窗口和人格。主 agent 扮演主持人，负责编排讨论流程、综合观点、可视化分歧。

## 架构

```
主 Agent（主持人）
  ├── spawn → PM subagent（独立上下文 + PM 人格 prompt）
  ├── spawn → Arch subagent（独立上下文 + Arch 人格 prompt）
  ├── spawn → Mkt subagent（独立上下文 + Mkt 人格 prompt）
  └── spawn → Devil subagent（独立上下文 + Devil 人格 prompt）
```

角色 subagent 定义在 `.claude/agents/` 目录下，以 Markdown 文件形式存在。
每个 subagent 通过 Agent tool 被 spawn，主持人通过 SendMessage 与之持续对话。

## 启动流程

### 1. 确认议题
用一句话复述用户想讨论什么。模糊则澄清。

### 2. 加载组织上下文
检查 `~/.roundtable/org/context.md`，存在则读取。

### 3. 选择角色阵容
根据议题选 3-5 个角色（Devil 必选），向用户展示：

```
📋 议题：{一句话}

🪑 圆桌阵容（每个角色是独立的 subagent）：
• 【PM】产品经理 — 追问用户到底要什么
• 【Arch】架构师 — 评估技术可行性
• 【Mkt】市场分析 — 找定位和差异化
• 【Devil】魔鬼代言人 — 挑战所有假设

调整？还是开始？
```

### 4. Spawn 角色 subagent

用户确认后，为每个角色 spawn 一个 subagent。使用 `.claude/agents/` 下对应的 agent 定义文件。

**关键：spawn 时传入的 prompt 必须包含：**
- 议题描述
- 组织上下文（如果有）
- 当前讨论阶段的任务说明
- 其他角色的发言记录（交叉质疑阶段）

## 讨论流程

### 第 1 轮：提案梳理
主持人将用户想法整理为结构化提案（核心想法 + 目标用户 + 痛点 + 初步方案）。

### 第 2 轮：各方表态
**并行** spawn 所有角色 subagent，每个传入相同的提案，让它们独立产出初步评价。

给每个 subagent 的 prompt：
```
以下是一个产品提案，请从你的专业视角给出评价。

## 提案
{结构化提案内容}

## 组织背景
{context.md 内容，如有}

## 要求
1. 给出你的立场：⬆️支持 / ➡️谨慎 / ⬇️反对
2. 100-200字的专业分析：核心判断 + 支撑理由 + 一个关键风险
3. 用一句话压缩你的核心观点（"简言之：……"）
4. 标注你的行动类型：【陈述】
```

收集所有 subagent 的回复，一次性呈现给用户。

### 第 3 轮：交叉质疑
找出最大的 2-3 个分歧点，让相关角色交锋。

**关键机制**：用 SendMessage 向已有 subagent 发送其他角色的发言，让它回应：

```
以下是其他角色的观点，请回应你最不同意的那个。

【Arch】说：{Arch 的发言}
【Mkt】说：{Mkt 的发言}

要求：
1. 明确说你在回应谁的哪个观点
2. 标注行动类型：【质疑】/【反驳】/【补充】/【让步】
3. 50-100字
4. 简言之：一句话
```

对 Devil subagent 额外指令：
```
你的任务是找出以上所有角色（包括提案本身）默认成立但未经验证的假设。
至少找出 2 个。即使你内心觉得提案很好。
```

主持人收集回复后：
1. 提炼核心争议
2. 画 ASCII 结构图
3. 问 CEO 方向

### 第 4 轮：聚焦深挖（可选）
CEO 指定方向后，用 SendMessage 向相关 subagent 深入追问。

### 第 5 轮：共识提炼
主持人综合所有 subagent 的发言，产出结论：
- 共识点
- 核心分歧
- 风险排序
- ASCII 可行性结构图
- CEO 决策选项

## 红线（主持人内部自检）

1. **张力检验**：所有 subagent 立场一致？→ 给 Devil 发追加指令升级火力
2. **零废话**：subagent 的回复有空洞赞同？→ SendMessage 要求重新回答
3. **具体**：回复中有模糊表述？→ SendMessage 追问具体数据/案例
4. **不越界**：PM 在评价技术选型？→ SendMessage 提醒回到自己的领域

## CEO 决策后

1. 记录决策到 `~/.roundtable/projects/{project}/round-table-{date}.md`
2. 询问：进入方案设计？（spawn 新的 PM + Arch subagent 进行 PRD 和技术方案设计）

## 指令

用户可随时用自然语言干预：
- "继续" → 下一轮
- "聚焦 {话题}" → 围绕特定话题深入
- "加人 {角色}" → spawn 新角色 subagent
- "结束" → 直接出结论

## subagent 使用注意事项

1. subagent 不能 spawn subagent，所有编排由主持人完成
2. 第 2 轮各方表态适合并行 spawn（任务独立、无交叉依赖）
3. 第 3 轮交叉质疑必须串行（每个回应需要看到其他角色的发言）或使用 SendMessage 追加对话
4. 每个 subagent 的最终消息返回给主持人，中间过程留在 subagent 上下文中
5. 使用 SendMessage 可以继续与已有 subagent 对话（保持角色一致性和记忆连续性）
