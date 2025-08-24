{ pkgs, ... }:
{

  environment.systemPackages = [
    pkgs.cowsay
    pkgs.hyperfine
    pkgs.just
    pkgs.jq
    pkgs.gnumake
    pkgs.file
    pkgs.cron
    pkgs.screen
    pkgs.dysk
  ];
}
