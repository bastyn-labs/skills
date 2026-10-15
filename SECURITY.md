# Security policy

## Reporting a vulnerability

Do not open a public issue for a security problem.

Preferred channel: GitHub private vulnerability reporting at
https://github.com/bastyn-labs/skills/security/advisories/new

Alternative: email security@bastyn.ai.

## What to include

- Which skill is affected, and which release tag (for example `v1.0.0`).
- What an attacker gains if the problem is exploited.
- Steps to reproduce, or the file and line where you saw the problem.

## What to expect

| Stage | Target |
|---|---|
| Acknowledgement | 3 working days |
| Initial assessment | 10 working days |
| Fix or dated plan | 90 days |

## Skills are instructions, not just files

A skill is a set of instructions that an AI agent follows. A malicious or altered
skill can make an agent run harmful commands, so it is a security issue even if no
code in this repository changes. Report suspected tampering, hidden characters in a
skill file, or a file whose SHA-256 differs from the one in the release notes.
