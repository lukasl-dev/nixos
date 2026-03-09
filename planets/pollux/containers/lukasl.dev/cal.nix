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
    ${secret "password"} = {
      rekeyFile = ../../../../secrets/${secret "password"}.age;
      generator.script = "alnum";
      intermediary = true;
    };

    ${secret "htpasswd"} = {
      rekeyFile = ../../../../secrets/${secret "htpasswd"}.age;
      mode = "644";
      generator = {
        dependencies = {
          password = config.age.secrets.${secret "password"};
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
            htpasswd_filename = "/var/lib/radicale/collections/.htpasswd";
            htpasswd_encryption = "bcrypt";
          };

          storage = {
            type = "filesystem";
            filesystem_folder = "/var/lib/radicale/collections";
          };

          web = {
            type = "internal";
          };
        };
      };

      systemd.services.radicale.preStart = ''
        install -m 600 -o radicale -g radicale ${
          config.age.secrets.${secret "htpasswd"}.path
        } /var/lib/radicale/collections/.htpasswd
      '';

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
