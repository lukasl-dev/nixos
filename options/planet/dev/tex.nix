{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet.dev) tex;
in
{
  options.planet.dev.tex = {
    enable = lib.mkEnableOption "Enable tex";
  };

  config = lib.mkIf tex.enable {
    environment.systemPackages = with pkgs.unstable; [
      texliveFull
      graphviz
      librsvg
      inkscape
    ];
  };
}
