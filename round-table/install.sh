#!/bin/bash
# RoundTable 安装脚本
# 安装 Skill 文件和 Agent 定义文件到正确位置

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

SKILL_DIR="$HOME/.claude/skills/roundtable"
AGENT_DIR="$HOME/.claude/agents"
RT_DIR="$HOME/.roundtable"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🪑 安装 RoundTable"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. 安装 Skill
mkdir -p "$SKILL_DIR"
cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"
echo "✅ Skill 已安装到 $SKILL_DIR"

# 2. 安装 Agent 定义
mkdir -p "$AGENT_DIR"
for agent_file in "$SCRIPT_DIR"/rt-*.md; do
    if [ -f "$agent_file" ]; then
        cp "$agent_file" "$AGENT_DIR/"
        echo "✅ Agent $(basename "$agent_file" .md) 已安装"
    fi
done

# 3. 初始化 RoundTable 目录
mkdir -p "$RT_DIR/org"
mkdir -p "$RT_DIR/projects"

if [ ! -f "$RT_DIR/org/context.md" ]; then
    cat > "$RT_DIR/org/context.md" << 'CONTEXT'
# 组织上下文

> 填写你的背景信息，帮助圆桌角色更好地理解你的情况。

## 基本信息
- 领域/行业：
- 技术栈偏好：
- 商业模式：

## 约束条件
- 时间投入：（全职/兼职/业余）
- 预算范围：
- 技术能力：（前端/后端/全栈/非技术）

## 已有资源
- 现有产品/项目：
- 用户/受众规模：
- 分发渠道：

## 偏好
- 决策风格：（快速行动 / 深思熟虑）
- 风险偏好：（激进 / 稳健 / 保守）
CONTEXT
    echo "✅ 组织上下文模板已创建: $RT_DIR/org/context.md"
else
    echo "ℹ️  组织上下文已存在，跳过"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 安装完成"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "文件位置："
echo "  Skill:   $SKILL_DIR/SKILL.md"
echo "  Agents:  $AGENT_DIR/rt-*.md"
echo "  数据:    $RT_DIR/"
echo ""
echo "下一步："
echo "  1. 编辑 $RT_DIR/org/context.md 填写你的背景"
echo "  2. 重启 Claude Code"
echo "  3. 输入：圆桌讨论 {你的想法}"
echo ""
