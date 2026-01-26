{
  pkgs, lib, ... }:

{
  options.planet.development.tex = {
    enable = lib.mkEnableOption "Enable tex";
  };

  config = {
    environment.systemPackages = with pkgs.unstable; [
      texliveFull
      graphviz
      librsvg
      inkscape
    ];
  };
}
