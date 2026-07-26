{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.imagemagick ];
}
