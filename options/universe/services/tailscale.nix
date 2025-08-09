{ config, ... }:

{
  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--ssh" ];
    authKeyFile = config.sops.secrets."universe/tailscale/auth_key".path;
  };

  sops.secrets = {
    "universe/tailscale/auth_key" = { };
  };
}
