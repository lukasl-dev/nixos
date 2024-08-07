{ pkgs, ... }:

{
  home.packages = with pkgs; [
    graphviz
    texliveFull
  ];
}
