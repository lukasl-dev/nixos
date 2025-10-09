{ config, ... }:

{
  networking = {
    networkmanager.enable = false;

    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];

      secretsFile = config.sops.templates."planets/ida/wireless/secrets.conf".path;

      networks = {
        Leeb = {
          pskRaw = "ext:psk";
        };
      };
    };

    interfaces = {
      wlan0 = {
        useDHCP = true;
      };
    };
  };

  # expose ida.local
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };

  sops = {
    secrets."planets/ida/wireless/password" = { };

    templates."planets/ida/wireless/secrets.conf" = {
      content = ''
        psk=${config.sops.placeholder."planets/ida/wireless/password"}
      '';
    };
  };
}
