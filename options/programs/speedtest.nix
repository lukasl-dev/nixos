{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.speedtest-cli ];
}
