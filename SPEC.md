# SPEC

## §D — Description

A Nix-flake-packaged lefthook-compatible markdownlint wrapper for agentic
skill and command files. Disables rules MD031, MD040, MD041, and MD060 that
conflict with agentic-file patterns, filters `.md` files from staged/push
arguments, and exits cleanly when no matches are found. Distributed as a Nix
flake input and lefthook remote for developers maintaining agentic prompt
repos alongside strict markdownlint configs.

## §V — Invariants

1. Builds on aarch64-darwin, x86\_64-darwin, x86\_64-linux, aarch64-linux.
2. All bats unit tests pass before commit and push.
3. Exits 0 with no arguments.
4. Exits 0 when no arguments are `.md` files.
5. Silently skips files that do not exist on disk.
6. MD031, MD040, MD041, MD060 always disabled; MD013 capped at 500 chars.
7. Every lefthook action has a configurable timeout (default 30s).
8. All checks defined for both pre-commit and pre-push.
9. Shell scripts invoked with explicit `bash`, never `./script.sh`.
10. No embedded shell in Nix files; shell logic in `.sh` files.
11. CI: Linux on every PR/push; macOS on push and manual dispatch.
12. Dev shell auto-installs lefthook when hooks are absent.
13. `nix flake check` must pass.

## §I — Interfaces

### CLI

`lefthook-markdownlint-agentic [file ...]` — filters to existing `.md`
files, runs `markdownlint --config .markdownlint-agentic.yml --`.

### Environment variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT` | `30` | Kill timeout (seconds) |
| `BATS_LIB_PATH` | Set by dev shell | Bats helper library path |

### Nix outputs

| Output | Description |
| --- | --- |
| `packages.<system>.default` | Shell wrapper with markdownlint-cli |
| `devShells.<system>.default` | Dev shell with all tools |
| `devShells.<system>.ci` | CI-oriented shell |

### Config files

`lefthook.yml`, `lefthook-remote.yml`, `.markdownlint.yml`,
`.markdownlint-agentic.yml`, `.yamllint.yml`, `.editorconfig`,
`config/lefthook/file_size_limits.yml`.

## §T — Tasks

| status | id | goal |
| --- | --- | --- |
| `x` | T1 | Add `watch_file` entries in `.envrc` for flake modules |
| `x` | T2 | Add bats test verifying MD060 is accepted when disabled |
| `x` | T3 | Normalize bats load paths (`.bash` extension inconsistency) |
| `x` | T4 | Add `.md`/`.sh` to `file_size_limits.yml` |
| `x` | T5 | Add bats test for timeout env var behavior |
| `x` | T6 | Add bats test for mixed valid/invalid multi-file input |
| `x` | T7 | Pin lefthook remote refs to commits, not `main` |
| `x` | T8 | Add negative test: non-disabled rules still fail |

## §B — Bugs / Known Issues

(none)
