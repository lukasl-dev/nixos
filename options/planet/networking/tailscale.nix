{ lib, ... }:

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
    };

    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    # services.tailscale.enable = lib.mkForce false;
    # systemd.services.tailscaled.enable = lib.mkForce false;
    # systemd.services.tailscaled-autoconnect.enable = lib.mkForce false;
  };
}
