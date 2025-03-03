{
  config,
  pkgs,
  ...
}:

{
  environment.systemPackages = [
    pkgs.nextcloud-client
  ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;

    hostName = "localhost";
    config.adminpassFile = config.sops.secrets."nextcloud/admin_password".path;
    config.dbtype = "sqlite";
  };

  sops.secrets = {
    "nextcloud/admin_password" = {
      owner = "nextcloud";
    };
  };
}
