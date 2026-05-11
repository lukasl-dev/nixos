{ config, lib, ... }:

let
  inherit (config.planet.networking) tailscale;
in
{
  options.planet.networking = {
    tailscale = {
      authKey = lib.mkOption {
        type = lib.types.path;
        description = "Filepath containing auth key";
      };
    };
  };

  config = {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      extraUpFlags = [
        "--ssh"
        "--accept-dns=true"
      ];
      authKeyFile = tailscale.authKey;
    };

    networking.firewall.trustedInterfaces = lib.mkIf config.services.tailscale.enable [ "tailscale0" ];
  };
}
