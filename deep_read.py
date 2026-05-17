import os

target_dir = r'y:\pwl\code\plugins\Clippings'

# Read full content of the most important files
key_files = [
    '为什么有人开始用 CE 替代 Superpowers？关键不只是流程，而是\u201c记忆\u201d.md',
    '为什么需要一个 Multi-Pass Review Skill：让大模型代码审核从\u201c会说\u201d变成\u201c可控\u201d.md',
    '被安装43万次的\u201c自我进化\u201dskill，为什么在你的Agent身上毫无作用？.md',
    '别再用终端跑 Claude Code 了——真正拖慢你的，是你管理它的方式.md',
    '如果不开启这个环境变量，你的 Claude Code 可能只发挥了 50% 的功力。.md',
    '这个 Skill 太硬了，刚开源就斩获 2.8K 星标！Agent 联网能力拉满！.md',
    '这个开源工具太猛了！让 Claude Code 成本爆降 89%.md',
    '谷歌开源一个神级 Skill，斩获 23000+ GitHub Star！.md',
    '又一个神级编程 Skill 开源！一套规则搞定 AI 编码从需求到上线全链路。.md',
    '开源神器！给 Claude Code 开上帝模式，解锁24+ 隐藏命令！无需 ProMax 也能用 Computer Use.md',
    '我给 Claude Code 装了个浏览器，它直接从会写代码变成了会干活.md',
    '我给自己的 Mac 装了过目不忘，然后让 Claude Code 替我回忆.md',
    '按角色选 Claude Code 配置：前端后端全栈各自的三个必装 Skills.md',
    '有人把 Claude Code 的用法扒成了百科全书，GitHub 斩获 4.3 万星.md',
    '装了一堆 Skills，结果每次都要手动喊它上场？.md',
    '让 Claude Code 成本爆降 80%，这个开源工具有点猛.md',
    '68.4k Star 的 DESIGN.md 仓库：AI 写前端，终于不靠\u201c感觉\u201d了.md',
    '78K Star的AI编程Skills：在开发前，先让grill-me 对你做一个\u201c需求访谈\u201d.md',
    'AutoResearch 实战：我让 Claude 自己打磨了一个\u201c信源可靠性研判\u201d Skill.md',
    'GitHub 2.3 万星神器！让 Claude Code 的 Team 协作\u201c看得见\u201d.md',
    '上海交大团队：让Claude Code在你睡觉时做\u201c靠谱\u201d科研，两篇论文被AI顶会接收-36氪.md',
    '在微信里使用 Claude Code，刚刚在 GitHub 上开源了这个 Skill 。.md',
    '基于 Claude Code + OpenSpec + Superpowers 构建档案编研智能辅助选题系统全流程.md',
    '姚金刚老师开源了自己的中文 AI 提示词库！在 Github 上狂揽 1800+ Stars！.md',
    '实战篇 Claude Code + superpowers + gstack 开发流程实录，可直接复制使用，一篇文章讲清楚！.md',
    '开发一个claude-code plugin？.md',
    '我把 Claude Code 的两个神器叠在一起：150K star 管思维，90K star 管执行，效果超出预期.md',
    '我最推荐的 5 个 Skills：找不到，就自己造.md',
    '用Claude Code做需求拆解：比你自己想得更细.md',
    '给 Claude Code 装上\u201c自我进化\u201d引擎：OpenSpace 安装使用指北.md',
    '装了Superpowers还是不会用？这套完整工作流，让你的AI从工具变成搭档.md',
    '让 AI 帮你更好地写代码：OpenSpec + Superpowers 通俗指南.md',
    '让 Claude Code 成本爆降 80%，这个开源工具有点猛 1.md',
    '16.5K+ star GitHub 热榜爆款：这个开源项目让 AI 自主完成整个 PRD.md',
    '3小时斩获 2K+ Star，Karpathy 新项目让 GitHub 又沸腾了.md',
    '5个Claude Code神级Skill：第三个让我每天多睡1小时.md',
    'Claude Code + Source-Verifier-skill：独家的信源可靠性验证工具.md',
]

output_path = r'y:\pwl\code\plugins\deep_analysis.txt'
with open(output_path, 'w', encoding='utf-8') as out:
    for fname in key_files:
        path = os.path.join(target_dir, fname)
        if not os.path.exists(path):
            out.write(f'\nNOT FOUND: {fname[:60]}\n')
            continue
        
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        out.write(f'\n{"="*70}\n')
        out.write(f'FILE: {fname}\n')
        out.write(f'{"="*70}\n')
        out.write(content)
        out.write('\n')

print(f'Written {len(key_files)} files to {output_path}')