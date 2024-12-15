{ config, ... }:

{
  services.harmonia = {
    enable = true;

    signKeyPaths = [ (config.sops.secrets."harmonia/secret".path) ];
  };

  nix.settings.allowed-users = [ "harmonia" ];

  networking.firewall.allowedTCPPorts = [
    443
    80
  ];

  security.acme = {
    defaults.email = "acme@lukasl.dev";
    acceptTerms = true;
  };

  services.nginx = {
    enable = true;

    recommendedTlsSettings = true;
    virtualHosts."nix.lukasl.dev" = {
      enableACME = true;
      forceSSL = true;

      locations."/".extraConfig = ''
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_redirect http:// https://;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';
    };
  };
}
