{
  fff,
  pi-codex-conversion,
  pkgs,
}:

let
  pi-fff = import ./pi-fff.nix { inherit fff pkgs; };
  pi-usage = import ./pi-usage.nix { inherit pkgs; };
  pi-exa = import ./pi-exa.nix { inherit pkgs; };
  pi-honcho-memory = import ./pi-honcho-memory.nix { inherit pkgs; };
  pi-subagents = import ./pi-subagents.nix { inherit pkgs; };
in
[
  ./wakatime.ts
  ./opencode-free.ts
  "${pi-fff}/packages/pi-fff"
  "${pi-usage}/usage-extension"
  "${pi-exa}/extensions/index.ts"
  "${pi-honcho-memory}/extensions/index.ts"
  "${pi-codex-conversion}"
  "${pi-subagents}"
]
