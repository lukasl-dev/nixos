{
  config,
  lib,
  ...
}:

let
  inherit (config) age;

  password = "planets/ida/wireless/password";
  secrets = "planets/ida/wireless/secrets.conf";
in
{
  networking = {
    networkmanager.enable = lib.mkForce false;

    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
      secretsFile = age.secrets.${secrets}.path;

      networks.Leeb.pskRaw = "ext:psk";
    };

    interfaces.wlan0.useDHCP = true;
  };

  age.secrets = {
    ${password}.rekeyFile = ../../secrets/planets/ida/wireless/password.age;

    ${secrets} = {
      rekeyFile = ../../secrets/planets/ida/wireless/secrets.conf.age;
      owner = "wpa_supplicant";
      group = "wpa_supplicant";
      mode = "0400";
      generator = {
        dependencies.password = age.secrets.${password};
        script =
          { decrypt, deps, ... }:
          ''
            password="$(${decrypt} "${deps.password.file}")"
            printf 'psk=%s\n' "$password"
          '';
      };
    };
  };
}
