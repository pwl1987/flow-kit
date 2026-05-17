import os, re, json

target_dir = r'y:\pwl\code\plugins\Clippings'

# All files that need analysis (from the unanalyzed list)
files_to_read = [
    '为什么有人开始用 CE 替代 Superpowers？关键不只是流程，而是\u201c记忆\u201d.md',
    '为什么需要一个 Multi-Pass Review Skill：让大模型代码审核从\u201c会说\u201d变成\u201c可控\u201d.md',
    '68.4k Star 的 DESIGN.md 仓库：AI 写前端，终于不靠\u201c感觉\u201d了.md',
    '78K Star的AI编程Skills：在开发前，先让grill-me 对你做一个\u201c需求访谈\u201d.md',
    'AutoResearch 实战：我让 Claude 自己打磨了一个\u201c信源可靠性研判\u201d Skill.md',
    'GitHub 2.3 万星神器！让 Claude Code 的 Team 协作\u201c看得见\u201d.md',
    '上海交大团队：让Claude Code在你睡觉时做\u201c靠谱\u201d科研，两篇论文被AI顶会接收-36氪.md',
    '被安装43万次的\u201c自我进化\u201dskill，为什么在你的Agent身上毫无作用？.md',
    '别再用终端跑 Claude Code 了——真正拖慢你的，是你管理它的方式.md',
    '又一个神级编程 Skill 开源！一套规则搞定 AI 编码从需求到上线全链路。.md',
    '在微信里使用 Claude Code，刚刚在 GitHub 上开源了这个 Skill 。.md',
    '基于 Claude Code + OpenSpec + Superpowers 构建档案编研智能辅助选题系统全流程.md',
    '如果不开启这个环境变量，你的 Claude Code 可能只发挥了 50% 的功力。.md',
    '姚金刚老师开源了自己的中文 AI 提示词库！在 Github 上狂揽 1800+ Stars！.md',
    '实战篇 Claude Code + superpowers + gstack 开发流程实录，可直接复制使用，一篇文章讲清楚！.md',
    '开发一个claude-code plugin？.md',
    '开源神器！给 Claude Code 开上帝模式，解锁24+ 隐藏命令！无需 ProMax 也能用 Computer Use.md',
    '我把 Claude Code 的两个神器叠在一起：150K star 管思维，90K star 管执行，效果超出预期.md',
    '我最推荐的 5 个 Skills：找不到，就自己造.md',
    '我给 Claude Code 装了个浏览器，它直接从会写代码变成了会干活.md',
    '我给自己的 Mac 装了过目不忘，然后让 Claude Code 替我回忆.md',
    '按角色选 Claude Code 配置：前端后端全栈各自的三个必装 Skills.md',
    '有人把 Claude Code 的用法扒成了百科全书，GitHub 斩获 4.3 万星.md',
    '用Claude Code做需求拆解：比你自己想得更细.md',
    '给 Claude Code 装上\u201c自我进化\u201d引擎：OpenSpace 安装使用指北.md',
    '装了Superpowers还是不会用？这套完整工作流，让你的AI从工具变成搭档.md',
    '装了一堆 Skills，结果每次都要手动喊它上场？.md',
    '让 AI 帮你更好地写代码：OpenSpec + Superpowers 通俗指南.md',
    '让 Claude Code 成本爆降 80%，这个开源工具有点猛 1.md',
    '让 Claude Code 成本爆降 80%，这个开源工具有点猛.md',
    '谷歌开源一个神级 Skill，斩获 23000+ GitHub Star！.md',
    '这个 Skill 太硬了，刚开源就斩获 2.8K 星标！Agent 联网能力拉满！.md',
    '这个开源工具太猛了！让 Claude Code 成本爆降 89%.md',
    '16.5K+ star GitHub 热榜爆款：这个开源项目让 AI 自主完成整个 PRD.md',
    '3小时斩获 2K+ Star，Karpathy 新项目让 GitHub 又沸腾了.md',
    '5个Claude Code神级Skill：第三个让我每天多睡1小时.md',
    'Claude Code + Source-Verifier-skill：独家的信源可靠性验证工具.md',
    'Claude Code 必备神级Skill：impeccable，零设计基础也能写出专业级前端页面.md',
    'Claude的rewind功能，你真的用对了吗 1.md',
    'Claude的rewind功能，你真的用对了吗 2.md',
    'Claude的rewind功能，你真的用对了吗.md',
    'GitHub 26k 星标！Claude Code Templates：一行命令搞定各种配置！赶紧码住！.md',
    'GitHub 暴涨 70k Star！这个开源 AI 程序员同事，让我凌晨 2 点终于能睡个好觉了！.md',
    'Superpowers+Stitch+Claude Code：创作者中心实战全记录.md',
    'Superpowers和GSD都火了，但我选择打造最了解你的AI编程配置框架.md',
    'Windows + AMD ROCm + PyTorch：debuff拉满的6650xt A卡炼丹折腾经历.md',
    'YC 总裁开源了自己亲手写的 AI Agent 大脑，1 周就 1 万点赞。.md',
    'claude code ：实现代码自我迭代.md',
    'code-review-graph：Claude Code 本地知识图谱，减少 6.8 倍代码审查 Token !.md',
    'code-review-graph：让 AI 代码审查只读关键代码的利器.md',
    'code-review-graph：让 AI 代码审查更精准、更省 Token.md',
    'superpowers-zh Skills 软件开发应用指南.md',
    'superpowers-zh：17款AI工具通用的20个超能力.md',
    '一人一城：gstack+Superpowers.md',
    '上班族必装！7个让Claude Code原地起飞的神级Skill.md',
    '介绍一些我正在使用 claude code 的 skill 和 MCP.md',
    '别人还在吹Karpathy的知识库思路，已经有大神直接输出Skill，一键安装.md',
    '别再把 Skill 当插件用了，这 18 个最值得装的 Skills 我帮你筛完了.md',
    '开源了一个 oss-skill：蒸馏开源软件作者或项目.md',
    '我把 Karpathy 的 AutoResearch 搬到了软件开发领域，效果炸了.md',
    '我试了下 Graphify，发现它可能是今年最容易被低估的 AI 代码理解神器.md',
    '放弃Vibe Coding：我用Superpowers+gstack沉淀出一套大幅减少返工的skill组合工作流（附案例）.md',
    '每个ide都可以使用！！我融合了superpowers、OpenSpec、spec-kit、GSD、gstack、claude-task-master写一套可控Ai开发规范流程.md',
    '每日一 Skills 推荐｜claude-task-master：给 AI 一份需求文档，它自己拆任务、排依赖、逐个交付.md',
    '热门Skill研究：pm-skills，这个GitHub项目，把顶级PM方法论装进了AI里.md',
    '融合了superpowers、OpenSpec、spec-kit、GSD、gstack...的可控Ai开发规范流程升级版来了！！.md',
    '140k Star！这个开源项目让你从零造出所有你爱的技术.md',
    '4个超强项目，让你的 Claude Code 如虎添翼.md',
    '5 天 5 万收藏的 GitHub 项目解决了 Claude Code 这个烦人问题。.md',
    'AMD显卡也能畅玩AI画图！ROCm+ComfyUI部署全指南.md',
    'Alan の分享 别再让 AI 工具互相打架了：Superpowers 与 gstack 的全局路由协议.md',
    'CE + Superpowers 三模型实测：Opus 4.6  Kimi K2.5  GLM-5 工程化实践对比.md',
    'Claude Code + MiniMax 2.7 + Superpowers：我是怎么真正交付一套生产系统的.md',
    'Claude Code 创始人力荐！一行命令打造24小时专属牛马，香麻了！.md',
    'Claude Code 拥有 50 多个命令。大多数开发者只用到 5 个.md',
    'Claude Code 提效的插件都安装哪些.md',
    'Claude Code 最佳实践全攻略：Karpathy Skills + claude-mem + Best Practice 三件套，让你的 AI 编程搭档脱胎换骨.md',
    'Claude Code 的记忆体系：CLAUDE.md + Rules + Auto Memory，三层配置让 AI 真正理解你的项目.md',
    'Claude Code 越用越卡？原因拆解与实战修复指南.md',
    'Claude Code 进阶指南：为什么高手都在同时用这两套 CLAUDE.md？.md',
    'Claude Code 钩子  技术文档.md',
    'Claude Code创始人力荐！一行命令打造24小时专属牛马，香麻了！.md',
    'Claude Code工作流选型指南：5套主流方案，哪套适合你？.md',
    'Claude Code第二个神器OpenSpace：让AI自己学会新技能，越用越便宜.md',
    'Claude悄悄史诗级更新Skill-creator！我把自己的Skill优化了一遍，效果惊人.md',
    'Skills赏析：使用skills-refiner提升skill质量.md',
    'Skill语法完全手册：从入门到精通，让AI100%按你的规则执行.md',
    'OpenSpec + Superpowers + gstack：一套让 AI 从「写代码」到「做项目」的组合拳.md',
    'OpenSpec + Superpowers TDD v2：4 层防护叠加 26 个原子任务，27 次 subagent 实测 34 通过.md',
    'OpenSpec 进阶：从 Core 到 Expanded，7个命令解锁全部工作流.md',
    'OpenSpec进阶：自研AI coder + openspec 完整实践指南.md',
    'Superpowers + GSD：Claude Code 的双模式工作流实战.md',
    'Superpowers 实战指南：7 步流程 + 14 个技能 + 3 条铁律，搭建让 AI 编程更稳、更守规矩的工作流.md',
    'Superpowers+Openspec两个AI编程框架一起用，我踩了7个坑.md',
    '实测对比3个让Agent质变的Skill：SuperpowerCEGstack，到底该怎么选？.md',
    '不可避免的未来：用 Claude Code 设计自己的 Agentic Coding 工作流.md',
    '从阶段到行动：全新 AI 规范驱动开发工作流 OpenSpec OPSX 完整指南.md',
    '如何把 Claude Code 改造成一个自进化系统：完整指南.md',
    '如何用CLAUDE.md把Claude Code调教成靠谱队友.md',
    '我在 Prompt 里加了四个字，Claude Code 的输出质量提升了一倍.md',
    'AI 编程工作流选型：Spec-Kit、OpenSpec、Superpowers 深度对比.md',
    'AI编程五把利器：GSD、Superpowers、Skills、OpenSpec、BMAD选哪个.md',
    '6 个代表性 AI 编程 Harness 工程化框架拆解：OpenSpec、Superpowers、GSD、OMC、ECC、Trellis 怎么选？.md',
    '6 大 Spec 驱动规范实测：我花两周扒完 BMAD、GStack 源码，结论有点意外.md',
    'Claude Code Task 系统：一个可能被很多人忽略的功能.md',
    'Claude Code auto mode实战：不用再狂按approve了.md',
    'Claude Code 团队落地指南：一套可复制的 配置方案.md',
    'Claude Code Token 优化 2026：把 API 账单砍 60-90% 的 5 个策略.md',
    'Claude Code 双插件最佳搭配：superpowers 当大脑，gstack 当手脚.md',
    'Ralph Wiggum 插件  技术文档.md',
    '子代理  技术文档.md',
    '技术文档.md',
    '深度拆解 Superpowers 和 gstack：AI 编程真正的差距，不在模型.md',
    '让 Claude Code 在你睡觉时持续运行：完整实战指南.md',
    'Claude 插件新组合：Superpowers + Ralph-Loop，效果大幅提升，让 AI 编程直接起飞.md',
    '忘掉 brainstorming：grill-me + trellis 的极简 vibe coding 工作流.md',
    '揭秘让Claude代码效率飙升10倍的settings.json神配置.md',
    'Mnilax：CLAUDE.md 规则从Karpathy的 4 条增加到 12 条，claude错误率从 41% 降到 3%.md',
    'GitHub 10万星 Claude Code 配置揭秘：84条实用规则精华.md',
    '8行代码让Claude Code闭嘴：输出token直降63%，废话全砍.md',
    '185000 星的 Superpowers 插件，90% 的人只用了它 10% 的功能.md',
    '71k Star 炸裂！Karpathy 新作 autoresearch：让 AI 替你做研究，你只管睡觉.md',
    '20K+ Star！Claude Code 多智能体编排神器！让 Claude Code 开挂，让你效率起飞！.md',
]

results = []
for fname in files_to_read:
    path = os.path.join(target_dir, fname)
    if not os.path.exists(path):
        continue
    
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    lines = content.split('\n')
    title = ''
    author = ''
    date = ''
    description = ''
    in_frontmatter = False
    
    for line in lines[:30]:
        if line.strip() == '---':
            if in_frontmatter:
                break
            in_frontmatter = True
            continue
        if in_frontmatter:
            if line.startswith('title:'):
                title = line.replace('title:', '').strip().strip('"').strip("'")
            elif line.startswith('author:'):
                author = line.replace('author:', '').strip()
            elif line.startswith('created:'):
                date = line.replace('created:', '').strip()
            elif line.startswith('description:'):
                description = line.replace('description:', '').strip().strip('"').strip("'")
    
    # Get body
    body_start = 0
    fm_count = 0
    for i, line in enumerate(lines):
        if line.strip() == '---':
            fm_count += 1
            if fm_count == 2:
                body_start = i + 1
                break
    
    body = '\n'.join(lines[body_start:])
    body = re.sub(r'!\[.*?\]\(.*?\)', '', body)
    body = re.sub(r'<[^>]+>', '', body)
    body = re.sub(r'\n{3,}', '\n\n', body)
    
    results.append({
        'filename': fname,
        'title': title,
        'author': author,
        'date': date,
        'description': description,
        'length': len(content),
        'body_preview': body[:500]
    })

# Write results to a file
output_path = r'y:\pwl\code\plugins\analysis_batch.txt'
with open(output_path, 'w', encoding='utf-8') as f:
    for r in results:
        f.write(f"\n{'='*60}\n")
        f.write(f"FILE: {r['filename'][:80]}\n")
        f.write(f"Title: {r['title']}\n")
        f.write(f"Author: {r['author']}\n")
        f.write(f"Date: {r['date']}\n")
        f.write(f"Desc: {r['description']}\n")
        f.write(f"Length: {r['length']} chars\n")
        f.write(f"{'='*60}\n")
        f.write(r['body_preview'])
        f.write('\n')

print(f'Processed {len(results)} files')
print(f'Output written to {output_path}')