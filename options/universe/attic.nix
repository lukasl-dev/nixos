{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.universe) domain user;

  client = pkgs.unstable.attic-client;
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

        token="$(cat ${config.age.secrets."universe/attic/token".path})"

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

  age.secrets = {
    "universe/attic/token" = {
      rekeyFile = ../../secrets/universe/attic/token.age;
      owner = user.name;
    };

    # TODO: remove
    "universe/github/username" = {
      rekeyFile = ../../secrets/universe/github/username.age;
      intermediary = true;
    };
    "universe/github/password" = {
      rekeyFile = ../../secrets/universe/github/password.age;
      intermediary = true;
    };

    "universe/attic/config" = {
      rekeyFile = ../../secrets/universe/attic/config.age;
      generator = {
        dependencies = {
          token = config.age.secrets."universe/attic/token";
        };
        script =
          { decrypt, deps, ... }:
          ''
            token="$(${decrypt} ${lib.escapeShellArg deps.token.file})"

            cat <<EOF
            default-server = "attic"

            [servers.attic]
            endpoint = "https://cache.${domain}"
            token = "$token"
            EOF
          '';
      };
      owner = user.name;
      path = "/home/${user.name}/.config/attic/config.toml";
    };

    "universe/nix-netrc" = {
      rekeyFile = ../../secrets/nix-netrc.age;
      generator = {
        dependencies = {
          atticToken = config.age.secrets."universe/attic/token";
          githubUsername = config.age.secrets."universe/github/username";
          githubPassword = config.age.secrets."universe/github/password";
        };
        script =
          {
            decrypt,
            deps,
            ...
          }:
          ''
            token="$(${decrypt} ${lib.escapeShellArg deps.atticToken.file})"
            github_username="$(${decrypt} ${lib.escapeShellArg deps.githubUsername.file})"
            github_password="$(${decrypt} ${lib.escapeShellArg deps.githubPassword.file})"

            cat <<EOF
            machine cache.${domain} password $token
            machine api.github.com login "$github_username" password "$github_password"
            EOF
          '';
      };
      owner = "root";
      path = "/etc/nix/netrc";
    };
  };
}
