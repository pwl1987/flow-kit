import os, re

target_dir = r'y:\pwl\code\plugins\Clippings'

files_to_read = [
    '为什么有人开始用 CE 替代 Superpowers？关键不只是流程，而是\u201c记忆\u201d.md',
    '为什么需要一个 Multi-Pass Review Skill：让大模型代码审核从\u201c会说\u201d变成\u201c可控\u201d.md',
    '68.4k Star 的 DESIGN.md 仓库：AI 写前端，终于不靠\u201c感觉\u201d了.md',
    '78K Star的AI编程Skills：在开发前，先让grill-me 对你做一个\u201c需求访谈\u201d.md',
    'AutoResearch 实战：我让 Claude 自己打磨了一个\u201c信源可靠性研判\u201d Skill.md',
    'GitHub 2.3 万星神器！让 Claude Code 的 Team 协作\u201c看得见\u201d.md',
    '上海交大团队：让Claude Code在你睡觉时做\u201c靠谱\u201d科研，两篇论文被AI顶会接收-36氪.md',
    '被安装43万次的\u201c自我进化\u201dskill，为什么在你的Agent身上毫无作用？.md',
]

for fname in files_to_read:
    path = os.path.join(target_dir, fname)
    if not os.path.exists(path):
        print(f'NOT FOUND: {fname[:60]}')
        continue
    
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract key info
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
    
    # Get first 2000 chars of body (after frontmatter)
    body_start = 0
    fm_count = 0
    for i, line in enumerate(lines):
        if line.strip() == '---':
            fm_count += 1
            if fm_count == 2:
                body_start = i + 1
                break
    
    body = '\n'.join(lines[body_start:body_start+80])
    # Clean body - remove image links and HTML
    body = re.sub(r'!\[.*?\]\(.*?\)', '[IMG]', body)
    body = re.sub(r'<[^>]+>', '', body)
    body = re.sub(r'\n{3,}', '\n\n', body)
    
    print(f'\n{"="*60}')
    print(f'FILE: {fname[:80]}')
    print(f'Title: {title}')
    print(f'Author: {author}')
    print(f'Date: {date}')
    print(f'Desc: {description}')
    print(f'Length: {len(content)} chars')
    print(f'{"="*60}')
    print(body[:2000])
    print()