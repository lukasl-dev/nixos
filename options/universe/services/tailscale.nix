{ config, lib, ... }:

{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [
      "--ssh"
      "--accept-dns=true"
    ];
    authKeyFile = config.age.secrets."universe/tailscale/auth_key".path;
  };

  age.secrets = {
    "universe/tailscale/auth_key" = {
      rekeyFile = ../../../secrets/universe/tailscale/auth_key.age;
    };
  };

  networking.firewall.trustedInterfaces = lib.mkIf config.services.tailscale.enable [ "tailscale0" ];
}
