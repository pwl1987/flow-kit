import os
import glob

target_dir = r'y:\pwl\code\plugins\Clippings'

# Key files to read - the ones most likely to have new insights
key_files = [
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
]

for fname in key_files:
    path = os.path.join(target_dir, fname)
    if os.path.exists(path):
        print(f'\n{"="*60}')
        print(f'FILE: {fname[:80]}')
        print(f'{"="*60}')
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
            # Print first 4000 chars
            print(content[:4000])
            if len(content) > 4000:
                print(f'\n... (truncated, total {len(content)} chars)')
    else:
        print(f'\nNOT FOUND: {fname[:60]}')