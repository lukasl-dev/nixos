# Rules

## Environment

- You are running on NixOS.
- If a required command is not installed in the current environment, you may use it from `nixpkgs`, for example via `nix shell` or `nix run`.
- In this setup, pi-mono (pi) paths are symlinks into the Nix store. Their original source paths in this repository are:
  - `~/.pi/agent/themes` → `~/nixos/options/universe/programs/pi-mono/themes`
  - `~/.pi/agent/extensions` → `~/nixos/options/universe/programs/pi-mono/extensions`
  - `~/.pi/agent/skills` → `~/nixos/options/universe/programs/pi-mono/skills`
  - `~/.pi/agent/AGENTS.md` → `~/nixos/options/universe/programs/pi-mono/AGENTS.md`
- When you need to inspect or edit the user-managed sources, prefer the repository paths above rather than the resolved Nix store targets.
