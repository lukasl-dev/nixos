{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) catppuccin;

  theme = "catppuccin-${catppuccin.flavor}-${catppuccin.accent}.yml";
in
{
  environment = {
    systemPackages = [
      (pkgs.symlinkJoin {
        name = "eza-catppuccin-${catppuccin.flavor}-${catppuccin.accent}";
        paths = [ pkgs.eza ];
        nativeBuildInputs = [ pkgs.makeWrapper ];

        postBuild = ''
          mkdir -p "$out/share/eza"
          ln -s \
            ${lib.escapeShellArg "${catppuccin.sources.eza}/${catppuccin.flavor}/${theme}"} \
            "$out/share/eza/theme.yml"

          wrapProgram "$out/bin/eza" \
            --set-default EZA_CONFIG_DIR "$out/share/eza" \
            --add-flags "--git" \
            --add-flags "--icons auto"
        '';
      })
    ];

    shellAliases = {
      ls = "eza";
      ll = "eza -l";
      la = "eza -a";
      lt = "eza --tree";
      lla = "eza -la";
    };
  };
}
