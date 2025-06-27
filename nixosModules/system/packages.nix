{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nvd

    just
    jq

    gcc
    gnumake
    glib
    glibc
    cargo
    rustc
    nil
    file
    cron
    screen

    dysk
    pv
  ];
}
