{ config, ... }:

let
  meta = import ./meta.nix;

  sub = "todo";
  host = "${sub}.${meta.domain}";
  port = 3456;

  secret = path: "planets/pollux/lukasl.dev/todo/${path}";
in
{
  age.secrets = {
    ${secret "jwt"} = {
      rekeyFile = ../../../../secrets/${secret "jwt"}.age;
      generator.script = "alnum";
    };

    "universe/mail/bot" = {
      rekeyFile = ../../../../secrets/universe/mail/bot.age;
      intermediary = true;
    };

    ${secret "env"} = {
      rekeyFile = ../../../../secrets/${secret "env"}.age;
      generator = {
        dependencies = {
          jwt = config.age.secrets.${secret "jwt"};
          botpass = config.age.secrets."universe/mail/bot";
        };
        script =
          { decrypt, deps, ... }:
          ''
            jwt="$(${decrypt} "${deps.jwt.file}")"
            botpass="$(${decrypt} "${deps.botpass.file}")"

            cat <<EOF
            VIKUNJA_SERVICE_JWTSECRET=$jwt
            VIKUNJA_MAILER_PASSWORD=$botpass
            EOF
          '';
      };
      owner = config.services.vikunja.user;
    };
  };

  pollux.containers.${meta.container} = [
    {
      services.vikunja = {
        enable = true;

        port = port;
        frontendHostname = host;
        frontendScheme = "https";

        database.type = "sqlite";
        database.path = "/var/lib/vikunja/vikunja.db";

        settings = {
          service = {
            timezone = "Europe/Berlin";
          };
          mailer = {
            enabled = true;
            host = "mail.lukasl.dev";
            port = 587;
            username = "bot@${meta.domain}";
            authtype = "plain";
          };
        };

        environmentFiles = [ config.age.secrets.${secret "env"}.path ];
      };

      networking.firewall.allowedTCPPorts = [ port ];
    }
  ];

  containers.${meta.container} = {
    bindMounts.${config.age.secrets.${secret "env"}.path} = {
      hostPath = config.age.secrets.${secret "env"}.path;
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
