{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:

let
  inherit (config.universe) domain user;

  client = pkgs-unstable.attic-client;
  cache = "universe";
in
{
  nix.settings.netrc-file = "/etc/nix/netrc";

  environment.systemPackages = lib.mkBefore [ client ];

  systemd.user.services."attic-use-${cache}" =
    let
      script = pkgs.writeShellScript "attic-use-${cache}" ''
        set -euo pipefail

        export HOME=${lib.escapeShellArg "/home/${user.name}"}
        export XDG_CONFIG_HOME="$HOME/.config"

        token="$(cat ${config.sops.secrets."universe/attic/token".path})"

        ${client}/bin/attic login --set-default attic "https://cache.${domain}" "$token"
        ${client}/bin/attic use attic:${cache}
      '';
    in
    {
      description = "Configure attic cache universe";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = script;
      };
    };

  sops = {
    secrets."universe/attic/token" = { };

    templates = {
      "universe/attic/config" = {
        content = ''
          default-server = "attic"

          [servers.attic]
          endpoint = "https://cache.${domain}"
          token = "${config.sops.placeholder."universe/attic/token"}"
        '';
        owner = user.name;
        path = "/home/${user.name}/.config/attic/config.toml";
      };

      "nix-netrc" = {
        content = ''
          machine cache.${domain} password ${config.sops.placeholder."universe/attic/token"}
        '';
        owner = "root";
        group = "users";
        mode = "0440";
        path = "/etc/nix/netrc";
      };
    };
  };
}
