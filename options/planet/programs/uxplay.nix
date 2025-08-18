{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  uxplay = config.planet.programs.uxplay;
in
{
  options.planet.programs.uxplay = {
    enable = lib.mkEnableOption "Enable UxPlay";
  };

  config = lib.mkIf uxplay.enable {
    environment.systemPackages = [ pkgs-unstable.uxplay ];

    networking.firewall = {
      allowedTCPPorts = [
        7000
        7100
        4000
        4001
        4002
      ];

      allowedUDPPorts = [
        5000
        5001
        5002

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
