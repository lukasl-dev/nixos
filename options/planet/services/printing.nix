{ config, lib, ... }:

let
  inherit (config.planet) wm;

  inherit (config.planet.services) printing;
in
{
  options.planet.services.printing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable printing";
    };
  };

  config = lib.mkIf printing.enable {
    services.printing.enable = true;

    # TODO: remove
    # services.avahi = {
    #   enable = true;
    #   nssmdns4 = true;
    #   publish = {
    #     enable = true;
    #     addresses = true;
    #     workstation = true;
    #     userServices = true;
    #   };
    # };
  };
}
