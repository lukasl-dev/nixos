{ lib, ... }:

{
  imports = [
    ./acme.nix
    ./proxy.nix

    ./matrix

    ./anki.nix
    ./backup.nix
    ./books.nix
    ./box.nix
    ./cache.nix
    ./cal.nix
    ./factorio.nix
    ./forge.nix
    ./hole.nix
    ./home.nix
    ./household.nix
    ./mail.nix
    ./notes.nix
    ./peers.nix
    ./status.nix
    ./stalwart.nix
    ./term.nix
    ./vault.nix
    ./waka.nix
    ./www.nix
    ./yam.nix
  ];

  options.galaxy.domain = lib.mkOption {
    type = lib.types.str;
    default = "lukasl.dev";
    description = "Base domain for galaxy services.";
  };
}
