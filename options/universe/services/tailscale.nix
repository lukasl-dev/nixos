{ config, lib, ... }:

{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    # Avoid DNS conflicts with Mullvad by keeping system DNS under your control.
    extraUpFlags = [ "--ssh" "--accept-dns=false" ];
    authKeyFile = config.sops.secrets."universe/tailscale/auth_key".path;
  };

  sops.secrets = {
    "universe/tailscale/auth_key" = { };
  };

  networking.firewall.trustedInterfaces = lib.mkIf config.services.tailscale.enable [ "tailscale0" ];
}
