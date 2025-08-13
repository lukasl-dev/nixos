{ config, ... }:

{
  services.tailscale = {
    enable = false;
    extraUpFlags = [ "--ssh" ];
    authKeyFile = config.sops.secrets."universe/tailscale/auth_key".path;
  };

  sops.secrets = {
    "universe/tailscale/auth_key" = { };
  };
}
