{ config, lib, ... }:

let
  sudo = config.planet.sudo;
in
{
  options.planet.sudo = {
    password = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Require password for sudo";
    };
  };

  config = {
    security.sudo = {
      enable = true;
      extraConfig = lib.mkIf (!sudo.password) ''
        %wheel ALL=(ALL) NOPASSWD: ALL
      '';
    };
  };
}
