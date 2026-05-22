# nix-lefthook-markdownlint-agentic

[![CI](https://github.com/pr0d1r2/nix-lefthook-markdownlint-agentic/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-markdownlint-agentic/actions/workflows/ci.yml)

> This code is LLM-generated and validated through an automated integration process using [lefthook](https://github.com/evilmartians/lefthook) git hooks, [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible [markdownlint](https://github.com/igorshubovych/markdownlint-cli) wrapper for agentic skill and command files, packaged as a Nix flake.

Uses relaxed markdownlint rules suited for agentic markdown files (Claude Code skills, commands, etc.) that don't follow standard documentation conventions:

- **MD013** (line length) -- disabled
- **MD024** (duplicate headings) -- disabled
- **MD031** (fenced code blocks in list items) -- disabled
- **MD040** (fenced code block language) -- disabled
- **MD041** (first line heading) -- disabled
- **MD060** (table column count) -- disabled

Filters `.md` files from staged arguments and runs markdownlint on them. Exits 0 when no matching files are found.

## Usage

### Option A: Lefthook remote (recommended)

Add to your `lefthook.yml` -- no flake input needed, just the wrapper binary in your devShell:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-markdownlint-agentic
    ref: main
    configs:
      - lefthook-remote.yml
```

### Option B: Flake input

Add as a flake input:

```nix
inputs.nix-lefthook-markdownlint-agentic = {
  url = "github:pr0d1r2/nix-lefthook-markdownlint-agentic";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add to your devShell:

```nix
nix-lefthook-markdownlint-agentic.packages.${pkgs.stdenv.hostPlatform.system}.default
```

Add to `lefthook.yml`:

```yaml
pre-commit:
  commands:
    markdownlint-agentic:
      glob: "*.md"
      run: timeout ${LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT:-30} lefthook-markdownlint-agentic {staged_files}
```

### Configuring timeout

The default timeout is 30 seconds. Override per-repo via environment variable:

```bash
export LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT=60
```

## Companion: nix-lefthook-markdownlint

Use alongside [nix-lefthook-markdownlint](https://github.com/pr0d1r2/nix-lefthook-markdownlint) for standard documentation files. In consuming repos, configure lefthook `exclude` patterns so each linter checks the appropriate files:

- **markdownlint** -- standard docs: README, CHANGELOG, SPEC, docs/
- **markdownlint-agentic** -- skill/command files: .claude/skills/, .claude/commands/, files/commands/, agent/

## Development

The repo includes an `.envrc` for [direnv](https://direnv.net/) -- entering the directory automatically loads the devShell with all dependencies:

```bash
cd nix-lefthook-markdownlint-agentic  # direnv loads the flake
bats tests/unit/
```

If not using direnv, enter the shell manually:

```bash
nix develop
bats tests/unit/
```

## License

MIT
