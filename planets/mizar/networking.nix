{
  config,
  lib,
  ...
}:

let
  inherit (config) age;

  password = "planets/mizar/wireless/password";
  secrets = "planets/mizar/wireless/secrets.conf";
in
{
  networking = {
    networkmanager.enable = lib.mkForce false;

    wireless = {
      enable = true;
      interfaces = [ "wlp4s0" ];
      secretsFile = age.secrets.${secrets}.path;

      networks.Leeb.pskRaw = "ext:psk";
    };

    interfaces = {
      enp0s31f6.useDHCP = true;
      wlp4s0.useDHCP = true;
    };
  };

  age.secrets = {
    ${password}.rekeyFile = ../../secrets/planets/mizar/wireless/password.age;

    ${secrets} = {
      rekeyFile = ../../secrets/planets/mizar/wireless/secrets.conf.age;
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
