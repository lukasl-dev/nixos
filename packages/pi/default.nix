{
  fff,
  pi-codex-conversion,
  pkgs,
  ...
}:

{
  pi.coding-agent = {
    rules = builtins.readFile ./AGENTS.md;

    themes = [ ./catppuccin-mocha.json ];

    skills = [
      ./skills/github
      ./skills/obsidian
      ./skills/tikzjax
      ./skills/zig
    ];

    extensions = import ./extensions {
      inherit fff pi-codex-conversion pkgs;
    };
  };
}
