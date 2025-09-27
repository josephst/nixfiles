# Repository Guidelines

## Project Structure & Module Organization
This flake-driven repo centralizes host and user configs under `flake.nix`, aided by helpers in `lib/helpers.nix`. Shared modules live in `modules/common/`, with Darwin-only logic in `modules/darwin/` and NixOS specifics in `modules/nixos/`. Host definitions sit in `hosts/`, while `home/` contains home-manager profiles (e.g., `home/joseph`). Custom packages and overlays reside in `pkgs/`, `pkgsLinux/`, and `overlays/`; secrets are age-encrypted in `secrets/` and user-scoped secrets under `home/joseph/secrets/`. Keep new modules small and compose them via imports in the relevant host file.

## Build, Test, and Development Commands
- `just switch`: stages changes with `git add --all`, then builds and activates the correct platform configuration.
- `nix develop`: enter a dev shell with repo toolchain and linting utilities.
- `nix flake check`: run evaluation, formatting, and lint checks; use before opening a PR.
- `nix build .#darwinConfigurations.<host>.system` or `.#nixosConfigurations.<host>.config.system.build.toplevel`: dry-run specific systems without switching.
- `nix fmt`: format Nix sources via `nixfmt`, `statix`, and `deadnix`. Run before committing.
- `just update` refreshes inputs; rerun `nix flake check` afterwards.

## Coding Style & Naming Conventions
Use two-space indentation and keep attribute keys in lowerCamelCase to match upstream Nix modules. Group related options alphabetically where practical, and prefer `enable = true;` feature flags over ad-hoc lists. Let `nix fmt` rewrite files; do not hand-format around tool output. Module names should mirror their directory (e.g., `modules/common/networking/default.nix` exports `modules.common.networking`).

## Testing Guidelines
Treat evaluation as the primary guardrail: run `nix flake check` plus targeted `nix build` commands for every touched host. When adjusting packages or overlays, build the derivation directly (e.g., `nix build .#pkgs.myPackage`). Use `nix build --dry-run` to confirm closure changes before deploying, and inspect failed builds with `nix log <drv>`.

## Commit & Pull Request Guidelines
Follow conventional commits (`feat(scope): …`, `fix(scope): …`, `chore: …`) as seen in history. Make each commit buildable and include configuration name in the scope when relevant (`feat(terminus): add tailscale`). PRs should describe motivation, list affected hosts, mention required secrets or migrations, and link issues when applicable. Before requesting review, ensure CI-quality checks (`nix fmt`, `nix flake check`, targeted builds`) are green and note any manual verification steps.

## Security & Secrets Management
Encrypt secrets with agenix and keep plaintext out of the repo. Use `agenix -e` for edits and `agenix -r` after adding new SSH keys under `keys/`. Validate that secrets paths referenced in modules exist before deployment to avoid switch failures.
