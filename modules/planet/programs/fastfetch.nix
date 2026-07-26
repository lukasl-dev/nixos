{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.fastfetch ];
}
