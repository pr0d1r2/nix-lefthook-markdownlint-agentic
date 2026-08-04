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
14. Non-agentic Markdown is silently skipped even when upstream routing passes it to the wrapper.

## §I — Interfaces

### CLI

`lefthook-markdownlint-agentic [file ...]` — filters to existing agentic `.md`
files under `agent/`, `.claude/`, and `files/commands/`, then runs
`markdownlint --config .markdownlint-agentic.yml --`.

`is-markdown-agentic <path>` — exits 0 when the path is Markdown under a
supported agentic directory and exits 1 otherwise.

### Environment variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT` | `30` | Kill timeout (seconds) |
| `BATS_LIB_PATH` | Set by dev shell | Bats helper library path |

### Nix outputs

| Output | Description |
| --- | --- |
| `packages.<system>.default` | Guarded shell wrapper with markdownlint-cli |
| `packages.<system>.is-markdown-agentic` | Agentic Markdown path classifier |
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

| id | date | cause | fix |
| --- | --- | --- | --- |
| B1 | 2026-07-20 | Confirm app missing fragment packages in runtimeInputs; coherence check fails (lefthook-markdownlint, lefthook-markdownlint-agentic, lefthook-yamllint not on PATH) | Add `mat.packages` to confirm app runtimeInputs |
| B2 | 2026-07-20 | Unused lambda patterns in outputs (deadnix failure) | Remove unused destructured inputs from outputs function |
| B3 | 2026-07-20 | Embedded shell (export statements) in flake.nix confirm app text block (nix-no-embedded-shell failure) | Extract shell to confirm.sh, call via `bash ${./confirm.sh}` |
| B4 | 2026-07-20 | flake.lock erroneously gitignored; dep-graph check fails on missing lock file | Remove flake.lock from .gitignore, track in git |
| B5 | 2026-07-20 | file\_size\_limits.yml too small for flake.lock (784KB > 256KB) and bats test (4716 > 4096) | Raise .lock limit to 1MB, .bats limit to 8KB |
| B6 | 2026-07-23 | Pin refresh grew generated flake.lock beyond the 1MB .lock file-size limit | Raise the .lock limit to 2MB |
| B7 | 2026-07-27 | Pin refresh grew generated flake.lock beyond the 2MB .lock limit; recording the failure grew SPEC.md beyond the 4KB .md limit | Raise the .lock limit to 4MB and .md limit to 8KB |
| B8 | 2026-07-29 | Pin refresh locked set-and-setting to rev d2fa92cc that lacks `lib` output, breaking flake evaluation (`attribute 'lib' missing`) | Update set-and-setting input to latest rev (92febe03) which restores `lib` |
| B9 | 2026-08-04 | Pin refresh introduced flake-manifest-check failure: outputs used inline `let` block with top-level bindings (`supportedSystems`, `forAllSystems`, `fragments`) which the strict manifest checker rejects | Extract outputs body to `nix/outputs.nix`, delegate from `flake.nix` via `import ./nix/outputs.nix` |
