{ config, ... }:

let
  domain = config.universe.domain;
  seahubPort = 8000;
  fileserverPort = 8082;
in
{
  services.seafile = {
    enable = true;

    adminEmail = "me@${domain}";
    initialAdminPassword = "admin";

    ccnetSettings.General.SERVICE_URL = "https://files.${domain}";

    seafileSettings = {
      fileserver = {
        host = "127.0.0.1";
        port = fileserverPort;
      };
    };
    seahubAddress = "127.0.0.1:${toString seahubPort}";
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      seafile-files = {
        rule = "Host(`files.${domain}`) && PathPrefix(`/seafhttp`)";
        entryPoints = [ "websecure" ];
        service = "seafile-files";
        middlewares = [ "seafile-strip" ];
        priority = 100;
      };
      seafile-web = {
        rule = "Host(`files.${domain}`)";
        entryPoints = [ "websecure" ];
        service = "seafile-web";
        priority = 10;
      };
    };
    services = {
      seafile-web.loadBalancer = {
        passHostHeader = true;
        servers = [ { url = "http://127.0.0.1:${toString seahubPort}"; } ];
        serversTransport = "seafile-timeouts";
      };
      seafile-files.loadBalancer = {
        passHostHeader = true;
        servers = [ { url = "http://127.0.0.1:${toString fileserverPort}"; } ];
        serversTransport = "seafile-timeouts";
      };
    };
    middlewares.seafile-strip.stripPrefix.prefixes = [ "/seafhttp" ];
    serversTransports.seafile-timeouts.forwardingTimeouts = {
      dialTimeout = "30s";
      # Disable backend timeouts for long uploads/downloads; rely on Seafile/app limits instead.
      responseHeaderTimeout = "0s";
      idleConnTimeout = "0s";
    };
  };
}
