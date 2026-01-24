{ pkgs, ... }:

{
  universe.hm = [
    {
      programs.fzf = {
        enable = true;

        tmux.enableShellIntegration = true;
        enableBashIntegration = true;
        enableZshIntegration = true;

        historyWidgetOptions = [
          "--preview 'echo {} | ${pkgs.bat}/bin/bat -l sh --color=always --plain'"
          "--preview-window down:3:wrap"
          "--bind 'ctrl-/:toggle-preview'"
          "--color header:italic"
          "--header 'Press CTRL-/ to toggle preview'"
        ];
      };
    }
  ];
}
