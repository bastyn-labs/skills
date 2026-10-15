# Bastyn Labs skills

Public skills from Bastyn Labs, in the Agent Skills format. See https://agentskills.io
for the format.

## Skills

| Skill | What it does | Latest tag |
|---|---|---|
| `bastyn-copilot-studio-setup` | Walks a person through giving Bastyn read-only access to their Microsoft Copilot Studio agent activity. | `v1.0.0` |

## Install

```bash
npx skills add bastyn-labs/skills --skill bastyn-copilot-studio-setup
```

## Download one file

Pin a tag and check the hash:

```bash
curl -fsSL https://raw.githubusercontent.com/bastyn-labs/skills/v1.0.0/skills/bastyn-copilot-studio-setup/SKILL.md -o SKILL.md && shasum -a 256 SKILL.md
```

## Verify before you follow it

A skill is a set of instructions that an AI agent executes. Before you use one:

- Always pin a release tag. Never use `main`.
- Compare the SHA-256 of the file with the value listed in `CHANGELOG.md` and in the
  release notes for that tag.
- Read the file. Report anything suspicious as described in `SECURITY.md`.

## How we protect this repo

- `main` is protected.
- Tags matching `v*` are protected.
- Every pull request must pass `bastyn-scan` (https://github.com/bastyn-labs/bastyn-scan)
  and a skill-format check.
- A rule-guard check fails the PR if a skill loses a required safety phrase or gains a forbidden one (lists in `checks/`).
- The format check uses `skills-ref`, which its authors label demonstration-only. It is
  installed from a pinned commit.

## Adding a skill

1. Copy `template/` to `skills/<name>/`. The folder name must equal the `name` field.
2. Fill in `SKILL.md` and set `metadata.version`.
3. Open a pull request. A release tag follows after merge.

## Licence

Apache-2.0. See `LICENSE`.
