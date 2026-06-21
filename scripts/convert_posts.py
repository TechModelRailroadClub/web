#!/usr/bin/env python3
"""One-time conversion of Jekyll _posts/*.md into Hugo content/posts/*.md."""
import re
from pathlib import Path

SRC = Path("_posts")
DST = Path("content/posts")
DST.mkdir(parents=True, exist_ok=True)

FILENAME_RE = re.compile(r"^(\d{4})-(\d{2})-(\d{2})-(.+)\.md$")

for src_file in sorted(SRC.glob("*.md")):
    m = FILENAME_RE.match(src_file.name)
    if not m:
        raise ValueError(f"Unexpected filename: {src_file.name}")
    year, month, day, slug = m.groups()

    text = src_file.read_text()
    _, front_matter, body = text.split("---", 2)

    fields = {}
    for line in front_matter.strip().splitlines():
        key, _, value = line.partition(":")
        fields[key.strip()] = value.strip()

    title = fields["title"].strip().strip('"')
    author = fields.get("author", "").strip().strip('"')

    body = body.replace("{{ site.baseurl }}", "")
    body = body.strip() + "\n"

    new_front_matter = (
        "---\n"
        f'title: "{title}"\n'
        f"date: {year}-{month}-{day}T00:00:00-04:00\n"
        f'author: "{author}"\n'
        "---\n\n"
    )

    dst_file = DST / f"{year}-{month}-{day}-{slug}.md"
    dst_file.write_text(new_front_matter + body)

print(f"Converted {len(list(SRC.glob('*.md')))} posts -> {DST}")
