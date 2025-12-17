# Contributing

For contributors and forks.

## Pre-commit Hooks

This repo includes validation hooks that run on `git commit`:

| Check | Blocks? | Purpose |
|-------|---------|---------|
| Secrets | Yes | Detects real API keys, private keys, bcrypt hashes |
| Env vars | Yes | Ensures compose `${VAR}` are documented in `.env.example` |
| YAML syntax | Yes | Catches invalid YAML before it breaks deployment |
| Port/IP conflicts | Yes | Detects duplicate ports or static IPs |
| Compose drift | Warn | Flags Jellyfin/Plex inconsistencies |
| Hardcoded domain | Warn | Flags your domain in tracked files |

### Install

```bash
./setup-hooks.sh
```

### Test manually

```bash
./scripts/pre-commit
```

### Uninstall

```bash
rm .git/hooks/pre-commit
```

## Structure

```
scripts/
├── pre-commit              # Main hook (symlinked from .git/hooks/)
└── lib/
    ├── check-secrets.sh
    ├── check-env-vars.sh
    ├── check-yaml-syntax.sh
    ├── check-conflicts.sh
    ├── check-compose-drift.sh
    └── check-hardcoded-domain.sh
```
