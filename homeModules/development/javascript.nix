{ pkgs, ... }:

{
  programs.bun.enable = true;

  home.packages = [ pkgs.nodejs ];
}
