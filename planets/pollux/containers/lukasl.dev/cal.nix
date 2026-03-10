{ config, pkgs, ... }:

let
  meta = import ./meta.nix;

  sub = "cal";
  host = "${sub}.${meta.domain}";
  port = 5232;

  secret = path: "planets/pollux/lukasl.dev/cal/${path}";
in
{
  age.secrets = {
    "universe/cal/password" = {
      rekeyFile = ../../../../secrets/universe/cal/password.age;
      generator.script = "alnum";
      intermediary = true;
    };

    ${secret "htpasswd"} = {
      rekeyFile = ../../../../secrets/${secret "htpasswd"}.age;
      mode = "644";
      generator = {
        dependencies = {
          password = config.age.secrets."universe/cal/password";
        };
        script =
          { decrypt, deps, ... }:
          ''
            password="$(${decrypt} "${deps.password.file}")"
            echo "lukas:$(echo "$password" | ${pkgs.apacheHttpd}/bin/htpasswd -niBC 10 lukas | cut -d: -f2)"
          '';
      };
    };
  };

  pollux.containers.${meta.container} = [
    {
      services.radicale = {
        enable = true;

        settings = {
          server = {
            hosts = [ "${meta.address.local}:${toString port}" ];
          };

          auth = {
            type = "htpasswd";
            htpasswd_filename = "/var/lib/radicale/.htpasswd";
            htpasswd_encryption = "bcrypt";
          };

        };

        rights = {
          root = {
            user = ".+";
            collection = "";
            permissions = "R";
          };
          principal = {
            user = ".+";
            collection = "{user}";
            permissions = "RW";
          };
          calendars = {
            user = ".+";
            collection = "{user}/[^/]+";
            permissions = "rw";
          };
        };
      };

      systemd.tmpfiles.rules = [
        "C /var/lib/radicale/.htpasswd 0600 radicale radicale - ${
          config.age.secrets.${secret "htpasswd"}.path
        }"
      ];

      networking.firewall.allowedTCPPorts = [ port ];
    }
  ];

  containers.${meta.container} = {
    bindMounts.${config.age.secrets.${secret "htpasswd"}.path} = {
      hostPath = config.age.secrets.${secret "htpasswd"}.path;
      isReadOnly = true;
    };
  };

  services.traefik.dynamicConfigOptions.http =
    let
      name = meta.router sub;
    in
    {
      routers.${name} = {
        rule = "Host(`${host}`)";
        entryPoints = [ "websecure" ];
        service = name;
      };
      services.${name} = {
        loadBalancer.servers = [
          {
            url = "http://${meta.address.local}:${toString port}";
          }
        ];
      };
    };
}
