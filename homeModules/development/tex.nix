{ pkgs, ... }:

{
  home.packages = [
    pkgs.texliveFull
    pkgs.graphviz
    pkgs.librsvg
    pkgs.inkscape
  ];
}
