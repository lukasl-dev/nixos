{ config, lib, ... }:

{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [
      "--ssh"
      "--accept-dns=true"
    ];
    authKeyFile = config.sops.secrets."universe/tailscale/auth_key".path;
  };

  sops.secrets = {
    "universe/tailscale/auth_key" = { };
  };

  networking.firewall.trustedInterfaces = lib.mkIf config.services.tailscale.enable [ "tailscale0" ];
}
