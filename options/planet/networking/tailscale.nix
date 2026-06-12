{ config, ... }:

let
  inherit (config.age) secrets;

  authKey = "universe/tailscale/authKey";
in
{
  age.secrets = {
    ${authKey} = {
      rekeyFile = ../../../secrets/universe/tailscale/authKey.age;
    };
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = secrets.${authKey}.path;
    extraUpFlags = [
      "--ssh"
      "--accept-dns=true"
    ];
    extraSetFlags = [
      "--ssh"
      "--accept-dns=true"
    ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
