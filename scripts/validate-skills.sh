#!/usr/bin/env bash
# Validates every skill under skills/*/. Works on bash 3.2 (macOS) and Ubuntu.
set -euo pipefail

cd "$(dirname "$0")/.."

fail() {
  echo "ERROR: $1" >&2
  exit 1
}

if command -v sha256sum >/dev/null 2>&1; then
  hash_file() { sha256sum "$1" | awk '{print $1}'; }
elif command -v shasum >/dev/null 2>&1; then
  hash_file() { shasum -a 256 "$1" | awk '{print $1}'; }
else
  fail "neither sha256sum nor shasum is installed"
fi

# Prints the lines between the first two '---' lines of a file.
frontmatter() {
  awk '
    NR == 1 { if ($0 != "---") exit 1; next }
    $0 == "---" { exit }
    { print }
  ' "$1"
}

count=0
for dir in skills/*/; do
  [ -d "$dir" ] || continue
  dir="${dir%/}"
  folder="$(basename "$dir")"
  file="$dir/SKILL.md"
  count=$((count + 1))

  [ -f "$file" ] || fail "skill '$folder': SKILL.md is missing"

  skills-ref validate "$dir" || fail "skill '$folder': skills-ref validate failed"

  fm="$(frontmatter "$file")" || fail "skill '$folder': SKILL.md does not start with a '---' frontmatter block"

  name="$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -n 1 | sed 's/[[:space:]]*$//; s/^"\(.*\)"$/\1/; s/^'"'"'\(.*\)'"'"'$/\1/')"
  [ "$name" = "$folder" ] || fail "skill '$folder': frontmatter name '$name' does not match folder name"

  printf '%s\n' "$fm" | grep -q '^metadata:' \
    || fail "skill '$folder': frontmatter has no 'metadata:' block"
  printf '%s\n' "$fm" | grep -Eq '^[[:space:]]+version:' \
    || fail "skill '$folder': metadata has no 'version:' line"

  printf '%s  %s\n' "$folder" "$(hash_file "$file")"
done

[ "$count" -gt 0 ] || fail "no skill folders found under skills/"
echo "OK: $count skill(s) validated"
