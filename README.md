# nix-lefthook-markdownlint-agentic

[![CI](https://github.com/pr0d1r2/nix-lefthook-markdownlint-agentic/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-markdownlint-agentic/actions/workflows/ci.yml)

> This code is LLM-generated and validated through an automated integration process using [lefthook](https://github.com/evilmartians/lefthook) git hooks, [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible [markdownlint](https://github.com/igorshubovych/markdownlint-cli) wrapper for agentic skill and command files, packaged as a Nix flake.

Disables agentic-specific rules via `--disable` flags, so consuming repos can keep a strict `.markdownlint.yml` for documentation while this wrapper relaxes rules for skill/command files:

- **MD031** (fenced code blocks in list items) -- disabled via `--disable`
- **MD040** (fenced code block language) -- disabled via `--disable`
- **MD041** (first line heading) -- disabled via `--disable`
- **MD060** (table column count) -- disabled via `--disable`

The project's `.markdownlint.yml` is still respected for all other rules (e.g., MD013, MD024 if disabled there).

Filters staged arguments to agentic Markdown under `agent/`, `.claude/`, and
`files/commands/`, then runs markdownlint on that subset. Ordinary documentation
is skipped, and the wrapper exits 0 when no agentic files are found.

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

The packaged `is-markdown-agentic <path>` command exposes the same path
predicate used by the wrapper. Routing exclusions remain useful to avoid
unnecessary invocations, but the wrapper independently skips non-agentic paths
as a defense-in-depth measure.

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
