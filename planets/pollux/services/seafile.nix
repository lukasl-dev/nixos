{ config, ... }:

let
  domain = config.universe.domain;
in
{
  services.seafile = {
    enable = true;

    adminEmail = "me@${domain}";
    initialAdminPassword = "admin";

    ccnetSettings.General.SERVICE_URL = "https://cloud.${domain}";

    seafileSettings = {
      fileserver = {
        host = "unix:/run/seafile/server.sock";
      };
    };
  };
}
