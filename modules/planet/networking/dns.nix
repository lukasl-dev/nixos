{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.networking) dns;

  aliasHost = alias: "${alias}.${planet.name}.local";

  publishAlias =
    alias:
    pkgs.writeShellScript "publish-${alias}-alias" ''
      while true; do
        address="$(${lib.getExe' pkgs.iproute2 "ip"} -4 route get 1.1.1.1 \
          | ${lib.getExe pkgs.gawk} '
              {
                for (i = 1; i <= NF; i++) {
                  if ($i == "src") {
                    print $(i + 1)
                    exit
                  }
                }
              }
            ')"

        if [[ -n "$address" ]]; then
          exec ${lib.getExe' pkgs.avahi "avahi-publish"} \
            --address --no-reverse \
            ${lib.escapeShellArg (aliasHost alias)} "$address"
        fi

        sleep 1
      done
    '';
in
{
  options.planet.networking.dns = {
    discoverable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Make this machine discoverable (hostname.local).";
    };

    aliases = lib.mkOption {
      type = lib.types.listOf (lib.types.strMatching "[a-z0-9]([a-z0-9-]*[a-z0-9])?");
      default = [ ];
      example = [ "media" ];
      description = ''
        Additional mDNS aliases published as alias.hostname.local.
      '';
    };
  };

  config = {
    assertions = [
      {
        assertion = dns.aliases == [ ] || dns.discoverable;
        message = ''
          planet.networking.dns.aliases requires
          planet.networking.dns.discoverable to be enabled.
        '';
      }
      {
        assertion = dns.aliases == lib.unique dns.aliases;
        message = "planet.networking.dns.aliases must be unique.";
      }
    ];

    networking.networkmanager.dns = "systemd-resolved";

    services = {
      resolved = {
        enable = true;
        settings.Resolve = {
          FallbackDNS = [
            "1.1.1.1"
            "1.0.0.1"

            "8.8.8.8"
            "8.8.4.4"
          ];
          DNSStubListenerExtra = [
            planet.virtualisation.containers.dns
          ];
        };
      };

      avahi = lib.mkIf planet.networking.dns.discoverable {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
          enable = true;
          addresses = true;
          workstation = true;
          userServices = true;
        };
      };
    };

    systemd.services = lib.listToAttrs (
      map (alias: {
        name = "avahi-publish-${alias}";
        value = {
          description = "Publish ${aliasHost alias} over mDNS";
          wantedBy = [ "multi-user.target" ];
          requires = [ "avahi-daemon.service" ];
          after = [
            "avahi-daemon.service"
            "network-online.target"
          ];
          wants = [ "network-online.target" ];

          serviceConfig = {
            ExecStart = publishAlias alias;
            Restart = "always";
            RestartSec = 5;
          };
        };
      }) dns.aliases
    );
  };
}
