{
  config,
  lib,
  atlas,
  ...
}:

let
  inherit (config) planet;
in
{
  imports = [
    ./desktop
    ./gaming
    ./hardware
    ./networking
    ./programs
    ./services
    ./virtualisation

    ./age.nix
    ./catppuccin.nix
    ./hjem.nix
    ./keys.nix
    ./nix.nix
    ./sound.nix
    ./sudo.nix
    ./time.nix
    ./travellers.nix
  ];

  options.planet = {
    name = lib.mkOption {
      type = lib.types.str;
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = atlas.domain;
    };

    stateVersion = lib.mkOption {
      type = lib.types.str;
    };

    modules = lib.mkOption {
      type = lib.types.listOf lib.types.deferredModule;
      default = [ ];
    };
  };

  config = {
    networking = {
      inherit (planet) domain;
      hostName = planet.name;
    };

    system.stateVersion = planet.stateVersion;

    i18n = {
      defaultLocale = "en_GB.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "en_GB.UTF-8";
        LC_IDENTIFICATION = "en_GB.UTF-8";
        LC_MEASUREMENT = "en_GB.UTF-8";
        LC_MONETARY = "en_GB.UTF-8";
        LC_NAME = "en_GB.UTF-8";
        LC_NUMERIC = "en_GB.UTF-8";
        LC_PAPER = "en_GB.UTF-8";
        LC_TELEPHONE = "en_GB.UTF-8";
        LC_TIME = "en_GB.UTF-8";
      };
    };
  };
}
