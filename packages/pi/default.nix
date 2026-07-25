{
  pi.coding-agent = {
    rules = builtins.readFile ./AGENTS.md;

    skills = [
      ./skills/github
      ./skills/obsidian
      ./skills/tikzjax
      ./skills/zig
    ];
  };
}
