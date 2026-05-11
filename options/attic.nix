{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet) domain user attic;
  inherit (pkgs.unstable) attic-client;
in
{
  options.planet = {
    attic = {
      cache = lib.mkOption {
        type = lib.types.str;
        description = "Attic cache";
        default = "universe";
      };

      endpoint = lib.mkOption {
        type = lib.types.str;
        description = "Attic endpoint";
        default = "https://cache.${domain}";
      };

      token = lib.mkOption {
        type = lib.types.path;
        description = "Attic auth token";
      };
    };
  };

  config = {
    environment.systemPackages = [ attic-client ];

    systemd.user.services."attic-use-${attic.cache}" =
      let
        script =
          pkgs.writeShellScript "attic-use-${attic.cache}"
            # bash
            ''
              set -euo pipefail

              export HOME=${lib.escapeShellArg "/home/${user.name}"}
              export XDG_CONFIG_HOME="$HOME/.config"

              mkdir -p "$XDG_CONFIG_HOME/attic"
              token="$(cat ${attic.token})"

              ${attic-client}/bin/attic login --set-default attic "${attic.endpoint}" "$token"
              ${attic-client}/bin/attic use attic:${attic.cache}
            '';
      in
      {
        description = "Configure attic caching";
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = script;
        };
      };
  };
}
