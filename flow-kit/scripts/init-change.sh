#!/bin/bash
set -euo pipefail
# init-change.sh — flow-kit 变更初始化脚本 v1.13
# 功能: 自动创建变更规格目录 + change-id + 项目类型检测 + 护栏推荐 + 下一步建议
# 用法: ./init-change.sh "变更描述"

# 加载路径管理
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"

# ============================================================================
# 主函数
# ============================================================================

main() {
    local description="${1:-}"

    if [ -z "$description" ]; then
        echo "用法: ./init-change.sh \"变更描述\""
        echo "示例: ./init-change.sh \"添加用户反馈中心模块\""
        exit 1
    fi

    # 1. 生成 change-id
    local change_id
    change_id=$(generate_change_id "$description")

    # 2. 创建目录结构
    local specs_dir="$PROJECT_DIR/.specs/${change_id}"
    mkdir -p "$specs_dir"

    # 3. 创建标准文件骨架
    create_skeleton_files "$specs_dir" "$change_id"
    local escaped_change_id
    escaped_change_id=$(printf '%s\n' "$change_id" | sed 's/[&\\/]/\\&/g')
    sed -i "s/{{change_id}}/${escaped_change_id}/g" "$specs_dir"/*.md

    # 4. 检测项目类型
    local project_type
    project_type=$(detect_project_type)

    # 5. 输出护栏推荐
    print_guardrail_recommendation "$project_type"

    # 6. 写入初始阶段状态
    echo "0" > "$CURRENT_PHASE_FILE"
    echo "💾 当前阶段已记录: Phase 0"

    # 7. 输出下一步建议
    print_next_steps "$change_id"
}

# ============================================================================
# 辅助函数
# ============================================================================

# 生成 change-id
# 格式: {slugified-description}-{YYYYMMDD}
generate_change_id() {
    local desc="$1"
    local date
    date=$(date +%Y%m%d)
    local slug=""

    # 提取中文词语（alternation 匹配）
    local chinese
    chinese=$(echo "$desc" | grep -oE '测试|变更|添加|用户|功能|开发|设计|模块|配置|管理|数据|接口|前端|后端|商务|论坛|博客|系统|新增|删除|修改|查询|列表|详情|登录|注册|退出' | head -4 | tr -d '\n')

    if [ -n "$chinese" ]; then
        slug="$chinese"
    else
        # 如果没有中文，用 sed 清理英文
        slug=$(echo "$desc" | sed 's/[^a-zA-Z0-9]/-/g' | sed 's/-+/-/g' | sed 's/^-//;s/-$//' | tr 'A-Z' 'a-z' | cut -c1-20)
    fi

    # 如果仍然为空，使用默认值
    if [ -z "$slug" ]; then
        slug="change"
    fi

    echo "${slug}-${date}"
}

# 创建标准文件骨架
create_skeleton_files() {
    local specs_dir="$1"
    local change_id="$2"

    # CHANGE.md - 变更摘要
    cat > "$specs_dir/CHANGE.md" << 'EOF'
# 变更摘要

## 变更 ID
{{change_id}}

## 变更类型
- [ ] Feature（功能新增）
- [ ] Bugfix（缺陷修复）
- [ ] Refactor（重构）
- [ ] Docs（文档更新）
- [ ] Config（配置变更）

## 变更摘要
{{summary}}

## 影响范围
- 修改文件：N 个
- 修改模块：N 个
- 风险等级：[高/中/低]

## 关联需求
{{related_requirements}}
EOF

    # REQUIREMENT.md - 需求文档
    cat > "$specs_dir/REQUIREMENT.md" << 'EOF'
# 需求文档

## 变更 ID
{{change_id}}

## 需求背景
{{background}}

## 功能需求

### 需求点 #1
**描述**：{{description}}

**验收标准**：
- Given {{condition}}
- When {{action}}
- Then {{result}}

## 非功能需求
- 性能：
- 安全：
- 兼容性：

## 边界条件
{{edge_cases}}
EOF

    # DESIGN.md - 架构设计
    cat > "$specs_dir/DESIGN.md" << 'EOF'
# 架构设计

## 变更 ID
{{change_id}}

## 技术方案
{{technical_approach}}

## 候选方案对比
| 方案 | 优点 | 缺点 | 推荐 |
|------|------|------|------|
| A    |      |      |      |

## 数据模型
{{data_model}}

## 回滚方案
{{rollback_plan}}
EOF

    # TASK.md - 任务列表
    cat > "$specs_dir/TASK.md" << 'EOF'
# 任务列表

## 变更 ID
{{change_id}}

## 任务拆解

### 任务 #1
**描述**：
**估计工时**：N 小时
**依赖**：
**可并行**：是/否

## 任务依赖图
{{dependency_graph}}
EOF

    # PROGRESS.md - 进度记录
    cat > "$specs_dir/PROGRESS.md" << 'EOF'
# 进度记录

## 变更 ID
{{change_id}}

## 当前阶段
Phase {{current_phase}}

## 完成情况
- [ ] Phase 0 变更立项
- [ ] Phase 1 需求澄清
- [ ] Phase 2 架构设计
- [ ] Phase 3 任务拆解
- [ ] Phase 4 开发执行
- [ ] Phase 5 测试验证
- [ ] Phase 6 代码审查
- [ ] Phase 7 集成归档
EOF
}

# 检测项目类型
detect_project_type() {
    if [ -f "$PROJECT_TYPE_FILE" ]; then
        local project_type
        project_type=$(grep -m1 "^project_type:" "$PROJECT_TYPE_FILE" 2>/dev/null | cut -d' ' -f2 || true)
        if [ -n "$project_type" ]; then
            echo "$project_type"
            return
        fi
    fi

    # 默认棕地（保守策略）
    echo "brownfield"
}

# 输出护栏推荐
print_guardrail_recommendation() {
    local project_type="$1"

    echo ""
    echo "=========================================="
    echo "flow-kit 变更初始化"
    echo "=========================================="
    echo ""
    echo "📋 项目类型: $project_type"

    if [ "$project_type" = "brownfield" ]; then
        echo ""
        echo "🛡️  推荐护栏配置: 棕地项目 - 启用全部护栏 B1-B6"
        echo "   原因: 已有代码库，需保护现有功能不破坏"
        echo "   命令: /flow-kit:ops-guard full"
    else
        echo ""
        echo "🛡️  推荐护栏配置: 绿地项目 - 启用核心护栏"
        echo "   原因: 新项目无历史包袱，可适度放宽，重点关注 B2/B4"
        echo "   命令: /flow-kit:ops-guard minimal"
    fi
}

# 输出下一步建议
print_next_steps() {
    local change_id="$1"

    echo ""
    echo "=========================================="
    echo "✅ 变更规格已创建: .specs/${change_id}/"
    echo "=========================================="
    echo ""
    echo "📌 下一步建议:"
    echo ""
    echo "   1. [推荐] 启动变更立项: /flow-kit:phase-0"
    echo "      原因: 进入 Phase 0 进行影响范围评估"
    echo ""
    echo "   2. [可选] 直接进入需求澄清: /flow-kit:phase-1"
    echo "      原因: 如果需求已明确，可跳过 Phase 0"
    echo ""
    echo "   3. [可选] 如需调整项目类型: /flow-kit:project-type [brownfield|greenfield]"
    echo "      原因: 当前自动检测可能不准确"
    echo ""
    echo "💡 输入 /flow-kit:next 可自动推进到下一步骤"
}

# ============================================================================
# 入口
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
