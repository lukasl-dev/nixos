{ pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./browsers.nix
    ./discord.nix
    ./nyxt.nix
    ./terminals.nix
  ];

  programs.sioyek.enable = true;
  programs.gpg.enable = true;
  services.easyeffects.enable = true;

  home.packages = [
    # messengers
    pkgs.zapzap

    # obsidian
    pkgs-unstable.obsidian

    # anki learn cards
    pkgs-unstable.anki

    # bitwarden
    pkgs-unstable.bitwarden
    pkgs-unstable.bitwarden-cli

    pkgs-unstable.calcure

    # youtube music
    pkgs-unstable.youtube-music
    pkgs-unstable.youtube-tui

    pkgs-unstable.pinta
  ];

  # thunderbird
  programs.thunderbird = {
    enable = true;

    profiles.default = {
      isDefault = true;
    };
  };

  programs.cava.enable = true;
}
