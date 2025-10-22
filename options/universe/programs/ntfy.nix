{ config, pkgs-unstable, ... }:

let
  inherit (config.universe) domain user;
in
{
  environment.systemPackages = [ pkgs-unstable.ntfy-sh ];

  sops = {
    secrets = {
      "universe/ntfy/user" = { };
      "universe/ntfy/password" = { };
    };

    templates."universe/ntfy/client" = {
      content = ''
        default-host: https://notify.${domain}
        default-user: ${config.sops.placeholder."universe/ntfy/user"}
        default-password: ${config.sops.placeholder."universe/ntfy/password"}
      '';
      owner = user.name;
      path = "/home/${user.name}/.config/ntfy/client.yml";
    };
  };
}
