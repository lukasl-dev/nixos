{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) display;
  inherit (config.planet.programs) localsend;
in
{
  options.planet.programs = {
    localsend = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = display.enable;
        description = "Enable LocalSend";
        example = "true";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open the firewall for LocalSend";
      };
    };
  };

  config = lib.mkIf localsend.enable {
    environment.systemPackages = [ pkgs.localsend ];

    networking.firewall = lib.mkIf localsend.openFirewall {
      allowedUDPPorts = [ 5353 ];
      allowedTCPPorts = [ 5353 ];
    };
  };
}
