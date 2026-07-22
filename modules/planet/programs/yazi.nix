{
  config,
  lib,
  ...
}:

let
  inherit (config) catppuccin;

  themeFile = "catppuccin-${catppuccin.flavor}-${catppuccin.accent}.toml";
  theme =
    lib.recursiveUpdate
      (lib.importTOML "${catppuccin.sources.yazi}/${catppuccin.flavor}/${themeFile}")
      {
        mgr.syntect_theme = "${catppuccin.sources.bat}/Catppuccin ${lib.toSentenceCase catppuccin.flavor}.tmTheme";
      };

  shellIntegration = ''
    function y() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
      command yazi "$@" --cwd-file="$tmp"
      if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }
  '';
in
{
  programs = {
    yazi = {
      enable = true;
      settings = { inherit theme; };
    };

    bash.interactiveShellInit = shellIntegration;
    zsh.interactiveShellInit = shellIntegration;
  };
}
