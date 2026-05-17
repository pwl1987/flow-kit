import os

target_dir = r'y:\pwl\code\plugins\Clippings'
all_files = sorted(os.listdir(target_dir))

analyzed = [
    'Superpowers 实战指南：7 步流程 + 14 个技能 + 3 条铁律，搭建让 AI 编程更稳、更守规矩的工作流.md',
    'Claude 插件新组合：Superpowers + Ralph-Loop，效果大幅提升，让 AI 编程直接起飞.md',
    '让 Claude Code 在你睡觉时持续运行：完整实战指南.md',
    '如何把 Claude Code 改造成一个自进化系统：完整指南.md',
    '深度拆解 Superpowers 和 gstack：AI 编程真正的差距，不在模型.md',
    'Ralph Wiggum 插件  技术文档.md',
    'Claude Code 钩子  技术文档.md',
    '子代理  技术文档.md',
    '技术文档.md',
    'Claude Code 双插件最佳搭配：superpowers 当大脑，gstack 当手脚.md',
    'Claude Code Token 优化 2026：把 API 账单砍 60-90% 的 5 个策略.md',
    'Claude Code 工作流选型指南：5套主流方案，哪套适合你？.md',
    'Skill语法完全手册：从入门到精通，让AI100%按你的规则执行.md',
    'Claude Code 的记忆体系：CLAUDE.md + Rules + Auto Memory，三层配置让 AI 真正理解你的项目.md',
    'Claude Code auto mode实战：不用再狂按approve了.md',
    '20K+ Star！Claude Code 多智能体编排神器！让 Claude Code 开挂，让你效率起飞！.md',
    'Claude Code 最佳实践全攻略：Karpathy Skills + claude-mem + Best Practice 三件套，让你的 AI 编程搭档脱胎换骨.md',
    '8行代码让Claude Code闭嘴：输出token直降63%，废话全砍.md',
    '忘掉 brainstorming：grill-me + trellis 的极简 vibe coding 工作流.md',
    '揭秘让Claude代码效率飙升10倍的settings.json神配置.md',
    'Claude Code 团队落地指南：一套可复制的 配置方案.md',
    'Claude Code 越用越卡？原因拆解与实战修复指南.md',
    '从阶段到行动：全新 AI 规范驱动开发工作流 OpenSpec OPSX 完整指南.md',
    'Mnilax：CLAUDE.md 规则从Karpathy的 4 条增加到 12 条，claude错误率从 41% 降到 3%.md',
    'GitHub 10万星 Claude Code 配置揭秘：84条实用规则精华.md',
    '如何用CLAUDE.md把Claude Code调教成靠谱队友.md',
    '我在 Prompt 里加了四个字，Claude Code 的输出质量提升了一倍.md',
    'AI 编程工作流选型：Spec-Kit、OpenSpec、Superpowers 深度对比.md',
    'AI编程五把利器：GSD、Superpowers、Skills、OpenSpec、BMAD选哪个.md',
    '6 个代表性 AI 编程 Harness 工程化框架拆解：OpenSpec、Superpowers、GSD、OMC、ECC、Trellis 怎么选？.md',
    '6 大 Spec 驱动规范实测：我花两周扒完 BMAD、GStack 源码，结论有点意外.md',
    'OpenSpec + Superpowers + gstack：一套让 AI 从「写代码」到「做项目」的组合拳.md',
    'OpenSpec + Superpowers TDD v2：4 层防护叠加 26 个原子任务，27 次 subagent 实测 34 通过.md',
    'OpenSpec 进阶：从 Core 到 Expanded，7个命令解锁全部工作流.md',
    'OpenSpec进阶：自研AI coder + openspec 完整实践指南.md',
    'Superpowers + GSD：Claude Code 的双模式工作流实战.md',
    'Superpowers+Openspec两个AI编程框架一起用，我踩了7个坑.md',
    '实测对比3个让Agent质变的Skill：SuperpowerCEGstack，到底该怎么选？.md',
    '不可避免的未来：用 Claude Code 设计自己的 Agentic Coding 工作流.md',
    'Claude Code Task 系统：一个可能被很多人忽略的功能.md',
    'Claude Code 进阶指南：为什么高手都在同时用这两套 CLAUDE.md？.md',
    'Claude Code创始人力荐！一行命令打造24小时专属牛马，香麻了！.md',
    'Claude Code 拥有 50 多个命令。大多数开发者只用到 5 个.md',
    'Claude Code 提效的插件都安装哪些.md',
    'Claude Code第二个神器OpenSpace：让AI自己学会新技能，越用越便宜.md',
    'Claude悄悄史诗级更新Skill-creator！我把自己的Skill优化了一遍，效果惊人.md',
    'Skills赏析：使用skills-refiner提升skill质量.md',
]

unanalyzed = []
for f in all_files:
    if not f.endswith('.md'):
        continue
    found = False
    for a in analyzed:
        if f == a:
            found = True
            break
    if not found:
        unanalyzed.append(f)

md_count = len([f for f in all_files if f.endswith('.md')])
print(f'Total .md files: {md_count}')
print(f'Analyzed: {len(analyzed)}')
print(f'Unanalyzed: {len(unanalyzed)}')
print()
for i, f in enumerate(unanalyzed):
    print(f'{i+1}. {f}')