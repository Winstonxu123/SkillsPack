#!/bin/bash
# RoundTable 通用版安装脚本
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

SKILL_DIR="$HOME/.claude/skills/roundtable"
AGENT_DIR="$HOME/.claude/agents"
RT_DIR="$HOME/.roundtable"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🪑 安装 RoundTable（通用版）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. 安装 Skill + references
mkdir -p "$SKILL_DIR/references"
cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"
cp "$SCRIPT_DIR/"*.md "$SKILL_DIR/references/" 2>/dev/null || true
echo "✅ Skill 已安装到 $SKILL_DIR"

# 2. 确保 agents 目录存在（agent 文件由运行时动态生成）
mkdir -p "$AGENT_DIR"
echo "✅ Agent 目录就绪: $AGENT_DIR"
echo "   （角色 agent 文件将在讨论启动时根据议题动态生成）"

# 3. 初始化数据目录
mkdir -p "$RT_DIR/discussions"

if [ ! -f "$RT_DIR/org/context.md" ]; then
    mkdir -p "$RT_DIR/org"
    cat > "$RT_DIR/org/context.md" << 'CONTEXT'
# 个人上下文

> 可选填写。帮助圆桌角色更好地理解你的背景。
> 留空也完全可以。

## 你是谁
-

## 你关注什么领域
-

## 你的偏好
- 决策风格：（快速行动 / 深思熟虑）
- 讨论喜好：（直接给结论 / 享受碰撞过程）
CONTEXT
    echo "✅ 个人上下文模板已创建"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 安装完成"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "使用方式："
echo "  在 Claude Code 中说：圆桌讨论 {任何话题}"
echo ""
echo "示例："
echo "  圆桌讨论 我要不要转行做独立开发者"
echo "  roundtable 这篇论文的研究方向值得做吗"
echo "  讨论一下 我的开源项目要不要商业化"
echo ""
