{ meta, config, ... }:

let
  postgresPort = config.services.postgresql.settings.port;
  postgresUser = "stack-auth";
  postgresDSN = "postgres://${postgresUser}:stack-auth@host.docker.internal:${toString postgresPort}/stack-auth";

  apiPort = 2094;
  dashboardPort = 2095;
in
{
  virtualisation.oci-containers.containers = {
    stack-auth = {
      image = "stackauth/server:latest";
      ports = [
        "${toString dashboardPort}:8101"
        "${toString apiPort}:8102"
      ];
      environment = {
        NEXT_PUBLIC_STACK_API_URL = "https://api.stack-auth.${meta.domain}";
        NEXT_PUBLIC_STACK_DASHBOARD_URL = "https://dashboard.stack-auth.${meta.domain}";
        STACK_DATABASE_CONNECTION_STRING = postgresDSN;
        STACK_DIRECT_DATABASE_CONNECTION_STRING = postgresDSN;
        STACK_SERVER_SECRET = "4ef6be2c-0081-43c0-89ce-1134550c248e"; # TODO: load from sops?
        STACK_SEED_INTERNAL_PROJECT_ALLOW_LOCALHOST = "true";
        STACK_SEED_INTERNAL_PROJECT_SIGN_UP_ENABLED = "true";
        STACK_RUN_MIGRATIONS = "true";
      };
    };
  };

  services.postgresql = {
    ensureUsers = [
      {
        name = postgresUser;
        ensureDBOwnership = true;
        ensureClauses = {
          login = true;
        };
      }
    ];
    ensureDatabases = [ postgresUser ];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      stack-auth-api = {
        rule = "Host(`api.stack-auth.${meta.domain}`)";
        entryPoints = [ "websecure" ];
        service = "stack-auth-api";
      };
      stack-auth-dashboard = {
        rule = "Host(`dashboard.stack-auth.${meta.domain}`)";
        entryPoints = [ "websecure" ];
        service = "stack-auth-dashboard";
      };
    };
    services = {
      stack-auth-api = {
        loadBalancer.servers = [ { url = "http://localhost:${toString apiPort}"; } ];
      };
      stack-auth-dashboard = {
        loadBalancer.servers = [ { url = "http://localhost:${toString dashboardPort}"; } ];
      };
    };
  };
}
