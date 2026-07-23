{
  lib,
  pkgs,
  ...
}:

{
  programs.fzf = {
    fuzzyCompletion = true;
    keybindings = true;
  };

  environment.variables = {
    FZF_TMUX = "1";
    FZF_CTRL_R_OPTS = lib.concatStringsSep " " [
      "--preview 'echo {} | ${lib.getExe pkgs.bat} -l sh --color=always --plain'"
      "--preview-window down:3:wrap"
      "--bind 'ctrl-/:toggle-preview'"
      "--color header:italic"
      "--header 'Press CTRL-/ to toggle preview'"
    ];
  };
}
