{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    cowsay
    hyperfine
    just
    jq
    gnumake
    file
    cron
    screen
    dysk
    attic-client
  ];
}
