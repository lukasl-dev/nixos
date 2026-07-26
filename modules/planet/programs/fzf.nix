{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) catppuccin;

  palette =
    (lib.importJSON "${catppuccin.sources.palette}/palette.json")
    .${catppuccin.flavor}.colors;

  colors = lib.mapAttrs (_: color: palette.${color}.hex) {
    "bg+" = "surface0";
    bg = "base";
    spinner = "rosewater";
    hl = catppuccin.accent;
    fg = "text";
    header = catppuccin.accent;
    info = catppuccin.accent;
    pointer = catppuccin.accent;
    marker = catppuccin.accent;
    "fg+" = "text";
    prompt = catppuccin.accent;
    "hl+" = catppuccin.accent;
  };

  colorOptions = lib.concatStringsSep "," (
    lib.mapAttrsToList (name: value: "${name}:${value}") colors
  );
in
{
  programs.fzf = {
    fuzzyCompletion = true;
    keybindings = true;
  };

  environment.variables = {
    FZF_DEFAULT_OPTS = "--color ${colorOptions}";
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
