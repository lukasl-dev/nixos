{ pkgs, pkgs-unstable, ... }:

{
  programs.bun = {
    enable = true;
    package = pkgs-unstable.bun;
  };

  home.packages = [ pkgs.nodejs ];
}
