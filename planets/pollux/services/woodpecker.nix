{ config, ... }:

let
  inherit (config.universe) domain;

  port = 3007;
in
{
  services = {
    woodpecker-server = {
      enable = true;
      environment = {
        WOODPECKER_HOST = "https://ci.${domain}";
        WOODPECKER_SERVER_ADDR = ":${toString port}";
        WOODPECKER_OPEN = "true";

        WOODPECKER_FORGEJO = "true";
        WOODPECKER_FORGEJO_URL = "https://forge.${domain}";
        WOODPECKER_ADMIN = "lukas";
      };
      environmentFile = config.sops.templates."planets/pollux/woodpecker/env".path;
    };

    woodpecker-agents.agents = {
      docker = {
        enable = true;
        extraGroups = [ "docker" ];
        environment = {
          WOODPECKER_SERVER = "localhost:9000";
          WOODPECKER_MAX_WORKFLOWS = "2";
          DOCKER_HOST = "unix:///var/run/docker.sock";
          WOODPECKER_BACKEND = "docker";
          # WOODPECKER_BACKEND_DOCKER_VOLUMES = "/nix/store:/nix/store:ro";
          WOODPECKER_HEALTHCHECK_ADDR = ":3008";
        };
        environmentFile = [
          config.sops.templates."planets/pollux/woodpecker/env".path
        ];
      };
      # local = {
      #   enable = true;
      #   environment = {
      #     WOODPECKER_SERVER = "localhost:9000";
      #     WOODPECKER_MAX_WORKFLOWS = "1";
      #     WOODPECKER_BACKEND = "local";
      #     WOODPECKER_HEALTHCHECK_ADDR = ":3008";
      #   };
      #   environmentFile = [
      #     config.sops.templates."planets/pollux/woodpecker/env".path
      #   ];
      # };
    };

    traefik.dynamicConfigOptions.http = {
      routers.woodpecker = {
        rule = "Host(`ci.${domain}`)";
        entryPoints = [ "websecure" ];
        service = "woodpecker";
      };
      services.woodpecker = {
        loadBalancer.servers = [
          {
            url = "http://localhost:${toString port}";
          }
        ];
      };
    };
  };

  sops = {
    secrets = {
      "planets/pollux/woodpecker/agent/secret" = { };
      "planets/pollux/woodpecker/forgejo/client" = { };
      "planets/pollux/woodpecker/forgejo/secret" = { };
    };
    templates."planets/pollux/woodpecker/env".content = ''
      WOODPECKER_AGENT_SECRET=${config.sops.placeholder."planets/pollux/woodpecker/agent/secret"}
      WOODPECKER_FORGEJO_CLIENT=${config.sops.placeholder."planets/pollux/woodpecker/forgejo/client"}
      WOODPECKER_FORGEJO_SECRET=${config.sops.placeholder."planets/pollux/woodpecker/forgejo/secret"}
    '';
  };
}
