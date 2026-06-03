{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet) name stateVersion;
  inherit (config.galaxy) lukasl-dev proxy;

  hostAliases = lib.unique (
    lib.map (
      rule: if rule.from.host != null then rule.from.host else "${rule.name}.${lukasl-dev.domain}"
    ) (proxy.rules.${lukasl-dev.domain} or [ ])
    ++ lib.optionals lukasl-dev.mail.enable [ lukasl-dev.mail.host ]
  );

  modules = lib.attrValues lukasl-dev.modules;
  guestModules = map (module: module.module) (lib.filter (module: module.mode == "guest") modules);
  hasModules = lukasl-dev.modules != { };
  hasGuestModules = guestModules != [ ];

  script = # bash
    ''
      set -euo pipefail

      if [ "$EUID" -eq 0 ]; then
        exec ${pkgs.nixos-container}/bin/nixos-container run lukasl-dev -- "$@"
      else
        exec sudo ${pkgs.nixos-container}/bin/nixos-container run lukasl-dev -- "$@"
      fi
    '';
in
{
  imports = [
    ./acme.nix
    ./proxy.nix

    ./matrix

    ./anki.nix
    ./backup.nix
    ./cache.nix
    ./books.nix
    ./box.nix
    ./cal.nix
    ./factorio.nix
    ./forge.nix
    ./household.nix
    ./hole.nix
    ./mail.nix
    ./notes.nix
    ./status.nix
    ./term.nix
    ./vault.nix
    ./waka.nix
    ./www.nix
    ./yam.nix
  ];

  options.galaxy = {
    lukasl-dev = {
      enable = lib.mkEnableOption "Join the lukasl-dev galaxy";

      domain = lib.mkOption {
        type = lib.types.str;
        default = "lukasl.dev";
        readOnly = true;
      };

      modules = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              mode = lib.mkOption {
                type = lib.types.enum [
                  "guest"
                  "host"
                ];
                default = lukasl-dev.mode;
                description = "Whether to place this module in the lukasl-dev container or on the host.";
              };

              module = lib.mkOption {
                type = lib.types.deferredModule;
                description = "NixOS module for this lukasl-dev service.";
              };
            };
          }
        );
        default = { };
        description = ''
          Named NixOS modules for lukasl-dev services.

          Guest modules are imported into the lukasl-dev container. Host modules
          are registered here for placement/metadata, but should also be applied
          directly by the service module to avoid recursive module evaluation.
        '';
        example = lib.literalExpression ''
          {
            example = {
              mode = "host";
              module = {
                services.example.enable = true;
              };
            };
          }
        '';
      };

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = "guest";
        description = "Default placement for lukasl-dev service modules.";
      };

      bindMounts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = age.identityPaths ++ age.masterIdentities;
        description = "Host paths to bind mount read-only into the lukasl-dev container.";
      };

      addresses = lib.mkOption {
        type = lib.types.submodule {
          options = {
            host = lib.mkOption {
              type = lib.types.str;
              readOnly = true;
            };

            local = lib.mkOption {
              type = lib.types.str;
              readOnly = true;
            };
          };
        };
        default = {
          host = "10.100.0.1";
          local = "10.100.0.2";
        };
        readOnly = true;
        description = "Network addresses for the lukasl-dev container.";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf lukasl-dev.enable (
      lib.mkMerge [
        {
          galaxy.proxy.enable = lib.mkIf hasModules true;
        }

        (lib.mkIf hasGuestModules {
          environment.systemPackages = [
            (pkgs.writeShellScriptBin "gld" script)
            (pkgs.writeShellScriptBin "g-lukasl-dev" script)
          ];

          # DNS
          services.resolved.extraConfig = "DNSStubListenerExtra=${lukasl-dev.addresses.host}";
          networking.firewall.interfaces."ve-lukasl-dev" = {
            allowedUDPPorts = [ 53 ];
            allowedTCPPorts = [ 53 ];
          };

          containers.lukasl-dev = {
            autoStart = true;
            specialArgs = { inherit inputs; };

            privateNetwork = true;
            hostAddress = lukasl-dev.addresses.host;
            localAddress = lukasl-dev.addresses.local;

            # enable nesting to allow docker to run inside the container
            additionalCapabilities = [ "all" ];

            bindMounts =
              let
                bindMount = path: {
                  name = path;
                  value = {
                    hostPath = path;
                    isReadOnly = true;
                  };
                };
              in
              lib.listToAttrs (map bindMount lukasl-dev.bindMounts);

            config = {
              imports = guestModules;

              system.stateVersion = stateVersion;

              networking = {
                hostName = "lukasl-dev";
                defaultGateway = lukasl-dev.addresses.host;
                hosts.${lukasl-dev.addresses.host} = lib.unique ([ "${name}.${lukasl-dev.domain}" ] ++ hostAliases);
                useHostResolvConf = false;
                nameservers = [ lukasl-dev.addresses.host ];
              };

              virtualisation = {
                docker.enable = true;
                oci-containers.backend = "docker";
              };
            };
          };
        })
      ]
    ))
  ];
}
