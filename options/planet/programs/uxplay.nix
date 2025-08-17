{
  config,
  lib,
  pkgs,
  ...
}:

let
  uxplay = config.planet.programs.uxplay;
in
{
  options.planet.programs.uxplay = {
    enable = lib.mkEnableOption "Enable UxPlay";

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open the firewall for LocalSend";
    };
  };

  config = lib.mkIf uxplay.enable {
    environment.systemPackages = [ pkgs.uxplay ];

    networking.firewall = lib.mkIf uxplay.openFirewall {
      allowedTCPPorts = [
        7000
        7100
        4000
        4001
      ];

      allowedUDPPorts = [
        6000
        6001
        7011
        5353
      ];
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
        userServices = true;
      };
    };
  };
}
