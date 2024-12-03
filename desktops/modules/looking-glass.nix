{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.looking-glass-client ];
}
