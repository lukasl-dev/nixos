{ pkgs, ... }:

{
  programs.texlive = {
    enable = true;
  };

  home.packages = with pkgs; [
    graphviz
  ];
}
