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
  };
}
