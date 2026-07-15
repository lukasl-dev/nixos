{ config, ... }:

let
  inherit (config) age;

  password = "planets/ida/wireless/password";
  secretsConf = "planets/ida/wireless/secrets.conf";
in
{
  networking = {
    networkmanager.enable = false;

    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];

      secretsFile = age.secrets.${secretsConf}.path;

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

  age.secrets = {
    ${password} = {
      rekeyFile = ../../secrets/planets/ida/wireless/password.age;
    };
    ${secretsConf} = {
      rekeyFile = ../../secrets/planets/ida/wireless/secrets.conf.age;
      owner = "wpa_supplicant";
      group = "wpa_supplicant";
      mode = "0400";
      generator = {
        dependencies = {
          password = age.secrets.${password};
        };
        script =
          { decrypt, deps, ... }:
          ''
            password="$(${decrypt} "${deps.password.file}")"

            cat <<EOF
            psk=$password
            EOF
          '';
      };
    };
  };
}
