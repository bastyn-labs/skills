#!/usr/bin/env bash
# Guards the non-negotiable rules of a skill against accidental edits.
# For each skills/<name>/, optional files checks/<name>.must (every line must appear in
# SKILL.md, case-insensitive) and checks/<name>.mustnot (no line may appear, exact case).
# Lines are fixed strings, not patterns. Works on bash 3.2 (macOS) and Ubuntu.
set -euo pipefail

cd "$(dirname "$0")/.."

failures=0
for dir in skills/*/; do
  [ -d "$dir" ] || continue
  name="$(basename "${dir%/}")"
  file="skills/$name/SKILL.md"

  if [ -f "checks/$name.must" ]; then
    while IFS= read -r phrase || [ -n "$phrase" ]; do
      [ -n "$phrase" ] || continue
      if ! grep -qiF -- "$phrase" "$file"; then
        echo "ERROR: skill '$name' lost a required phrase: $phrase" >&2
        failures=$((failures + 1))
      fi
    done < "checks/$name.must"
  fi

  if [ -f "checks/$name.mustnot" ]; then
    while IFS= read -r phrase || [ -n "$phrase" ]; do
      [ -n "$phrase" ] || continue
      if grep -qF -- "$phrase" "$file"; then
        echo "ERROR: skill '$name' contains a forbidden phrase: $phrase" >&2
        failures=$((failures + 1))
      fi
    done < "checks/$name.mustnot"
  fi
done

# The scope sanity rule must come BEFORE the command that creates the identity.
sanity='microsoft.insights/components/`. If it does not'
create='az ad sp create-for-rbac --name'
file="skills/bastyn-copilot-studio-setup/SKILL.md"
sanity_line="$(grep -nF -- "$sanity" "$file" | head -n 1 | cut -d: -f1)"
create_line="$(grep -nF -- "$create" "$file" | head -n 1 | cut -d: -f1)"
if [ -z "$sanity_line" ] || [ -z "$create_line" ] || [ "$sanity_line" -ge "$create_line" ]; then
  echo "ERROR: bastyn-copilot-studio-setup: the resource-id sanity rule must come before the create-for-rbac command" >&2
  failures=$((failures + 1))
fi

[ "$failures" -eq 0 ] || exit 1
echo "OK: skill rule guards passed"
