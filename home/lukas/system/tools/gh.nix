{ pkgs, ... }:

{
  programs.gh = {
    enable = false; # TODO: fix, home-manager crashes if enabled
  };

  home.packages = with pkgs; [ gh ];
}
