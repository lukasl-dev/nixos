#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 <query> [limit]" >&2
  echo "Example: $0 firefox 20" >&2
  exit 1
fi

query="$1"
limit="${2:-20}"
url="https://nix-community.github.io/home-manager/options.xhtml"

curl --fail --silent --show-error \
  --header 'User-Agent: pi-mono/1.0 (+https://github.com/lukasl-dev/rime)' \
  --header 'Accept: text/html' \
  "$url" | python3 -c '
import json
import re
import sys
from html import unescape

DESCRIPTION_LIMIT = 200

html = sys.stdin.read()
query = sys.argv[1].strip()
limit = int(sys.argv[2])

if not query:
    raise SystemExit("query must not be empty")

def clean_html_text(text: str) -> str:
    text = re.sub(r"<[^>]*>", " ", text)
    text = unescape(text)
    return " ".join(text.split())

def truncate_text(text: str, max_chars: int) -> str:
    if len(text) <= max_chars:
        return text
    return text[:max_chars] + "..."

def extract_first_paragraph(dd_block: str):
    match = re.search(r"<p[^>]*>(.*?)</p>", dd_block, re.IGNORECASE | re.DOTALL)
    if not match:
        return None
    text = clean_html_text(match.group(1))
    return text or None

def extract_description_before_type(text: str):
    idx = text.find("Type:")
    if idx == -1:
        return None
    desc = text[:idx].strip()
    return desc or None

def extract_description(dd_block: str) -> str:
    paragraph = extract_first_paragraph(dd_block)
    if paragraph is not None:
        return paragraph
    text = clean_html_text(dd_block)
    desc = extract_description_before_type(text)
    if desc is not None:
        return desc
    return text

def extract_section_html(input_text: str, label: str, stop_markers):
    idx = input_text.find(label)
    if idx == -1:
        return None
    rest = input_text[idx + len(label):]
    end = len(rest)
    for marker in stop_markers:
        marker_idx = rest.find(marker)
        if marker_idx != -1 and marker_idx < end:
            end = marker_idx
    return rest[:end]

def extract_section_value(dd_block: str, label: str, stop_markers) -> str:
    text = clean_html_text(dd_block)
    idx = text.find(label)
    if idx == -1:
        return ""
    rest = text[idx + len(label):].lstrip()
    if not rest:
        return ""
    end = len(rest)
    for marker in stop_markers:
        marker_idx = rest.find(marker)
        if marker_idx != -1 and marker_idx < end:
            end = marker_idx
    return rest[:end].strip()

def extract_type_info(dd_block: str) -> str:
    return extract_section_value(dd_block, "Type:", [
        "Default:",
        "Example:",
        "Declared by:",
        "Defined by:",
        "Related packages:",
        "Related options:",
    ])

def extract_default_value(dd_block: str) -> str:
    return extract_section_value(dd_block, "Default:", [
        "Example:",
        "Declared by:",
        "Defined by:",
        "Related packages:",
        "Related options:",
        "Type:",
    ])

def extract_links(section: str):
    links = []
    seen = set()
    for match in re.finditer(r"href\s*=\s*([\"\x27])(.*?)\1", section, re.IGNORECASE | re.DOTALL):
        url = unescape(match.group(2))
        if url and url not in seen:
            seen.add(url)
            links.append(url)
    return links

def extract_declared_by(dd_block: str) -> str:
    section = extract_section_html(dd_block, "Declared by:", [
        "Defined by:",
        "Related packages:",
        "Related options:",
        "Example:",
        "Default:",
        "Type:",
    ])
    if section is None:
        return ""
    links = extract_links(section)
    return ", ".join(links)

def extract_dd_block(html_text: str, cursor: int):
    match = re.search(r"<dd[^>]*>(.*?)</dd>", html_text[cursor:], re.IGNORECASE | re.DOTALL)
    if not match:
        return None, cursor
    dd_block = match.group(1)
    next_cursor = cursor + match.end()
    return dd_block, next_cursor

results = []
seen = set()
cursor = 0
query_lower = query.lower()
pattern = re.compile(r"id=\"opt-([^\"]+)\"")

while True:
    match = pattern.search(html, cursor)
    if not match:
        break
    raw_name = match.group(1)
    name = raw_name.replace("_name_", "<name>")
    cursor = match.end()

    if query_lower not in name.lower():
        continue
    if name in seen:
        continue
    seen.add(name)

    description = ""
    type_info = ""
    default_value = ""
    declared_by = ""
    next_cursor = cursor

    dd_block, dd_next_cursor = extract_dd_block(html, cursor)
    if dd_block is not None:
        description = extract_description(dd_block)
        type_info = extract_type_info(dd_block)
        default_value = extract_default_value(dd_block)
        declared_by = extract_declared_by(dd_block)
        next_cursor = dd_next_cursor

    if description:
        description = truncate_text(description.strip(), DESCRIPTION_LIMIT)

    results.append({
        "name": name,
        "description": description,
        "type_info": type_info.strip(),
        "default_value": default_value.strip(),
        "declared_by": declared_by.strip(),
    })

    cursor = next_cursor
    if len(results) >= limit:
        break

json.dump(results, sys.stdout)
sys.stdout.write("\n")
' "$query" "$limit"
