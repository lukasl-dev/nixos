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
      allowedUDPPorts = [ 5353 ];
      allowedTCPPorts = [ 5353 ];
    };
  };
}
