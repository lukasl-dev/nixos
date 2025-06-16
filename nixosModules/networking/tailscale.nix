{ config, ... }:

{
  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--ssh" ];
    authKeyFile = config.sops.secrets."tailscale/auth_key".path;
  };

  sops.secrets = {
    "tailscale/auth_key" = { };
  };
}
