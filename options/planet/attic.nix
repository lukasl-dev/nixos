{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.universe) domain user;
  inherit (config.planet) attic;

  cacheModule = lib.types.submodule (
    { name, ... }:
    {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = name;
          defaultText = "<attribute name>";
          description = "Cache identifier as seen on the Attic server.";
        };

        trusted-public-key = lib.mkOption {
          type = lib.types.str;
          example = "vega:B57uOXZgdBLi/6kEAnfmoIpIg+V8/RjLvxQI6iVCtO8=";
          description = "Public key advertised by the cache.";
        };
      };
    }
  );
in
{
  options.planet.attic = {
    enable = lib.mkEnableOption "Enable Attic binary cache";

    sops = {
      token = lib.mkOption {
        type = lib.types.str;
        description = "SOPS key for Attic client token";
      };
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.attic-client;
      defaultText = "pkgs.attic or pkgs.attic-client";
      description = "Package providing the Attic CLI.";
    };

    caches = lib.mkOption {
      type = lib.types.attrsOf cacheModule;
      default = { };
      example = {
        vega = {
          name = "vega";
          trusted-public-key = "vega:B57uOXZgdBLi/6kEAnfmoIpIg+V8/RjLvxQI6iVCtO8=";
        };
      };
      description = "Attic caches to configure as substituters.";
    };
  };

  config = lib.mkIf attic.enable {
    # nix.settings =
    #   let
    #     caches = builtins.attrValues attic.caches;
    #     substituters = map (cache: "https://cache.${domain}/${cache.name}") caches;
    #     publicKeys = map (cache: cache.trusted-public-key) caches;
    #   in
    #   {
    #     substituters = lib.mkBefore substituters;
    #     trusted-public-keys = lib.mkBefore publicKeys;
    #   };

    sops = {
      secrets.${attic.sops.token} = { };

      templates = {
        "planets/${config.planet.name}/attic/config" = {
          content = ''
            default-server = "attic"

            [servers.attic]
            endpoint = "https://cache.${domain}"
            token = "${config.sops.placeholder.${attic.sops.token}}"
          '';
          owner = user.name;
          path = "/home/${user.name}/.config/attic/config.toml";
        };

        # TODO: problematic if there are multiple .netrc files are required
        "planets/${config.planet.name}/attic/netrc" = {
          content = ''
            machine cache.${domain} password "${config.sops.placeholder.${attic.sops.token}}"
          '';
          owner = user.name;
          path = "/home/${user.name}/.netrc";
        };
      };
    };

    environment.systemPackages = lib.mkBefore [ attic.package ];

    systemd.user.services =
      let
        mkService =
          cache:
          let
            script = pkgs.writeShellScript "attic-use-${cache.name}" ''
              set -euo pipefail
              export HOME=${lib.escapeShellArg "/home/${user.name}"}
              export XDG_CONFIG_HOME="$HOME/.config"
              ${attic.package}/bin/attic use attic:${cache.name}
            '';
          in
          {
            description = "Configure Attic cache ${cache.name}";
            wantedBy = [ "default.target" ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = script;
            };
          };
      in
      lib.mkMerge (
        lib.mapAttrsToList (cacheName: cacheConfig: {
          "attic-use-${cacheName}" = mkService cacheConfig;
        }) attic.caches
      );
  };
}
