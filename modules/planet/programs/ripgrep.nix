{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ripgrep ];
}
