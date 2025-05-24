{ pkgs, ... }:

{
  imports = [ ./wine.nix ];

  home.packages = [ pkgs.lutris ];
}
