# Rules

## Environment

- You are running on NixOS.
- If a required command is not installed in the current environment, you may use it from `nixpkgs`, for example via `nix shell` or `nix run`.
- When you need to inspect or edit the user-managed sources, prefer the repository paths above rather than the resolved Nix store targets.

## Restrictions

- When connecting to non-local devices (e.g. via ssh), you're only allowed to perform read-only operations. Actions, such as modifications, restarts, and in particular deletions are strictly forbidden.  
