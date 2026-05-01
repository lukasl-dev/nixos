{ config, pkgs, ... }:

let
  inherit (config.universe) user domain;
in
{
  environment.systemPackages = with pkgs; [ wakatime-cli ];

  age.secrets = {
    "universe/wakatime/api_key" = {
      rekeyFile = ../../../secrets/universe/wakatime/api_key.age;
      intermediary = true;
    };

    "universe/wakatime/cfg" = {
      rekeyFile = ../../../secrets/universe/wakatime/cfg.age;
      generator = {
        dependencies = {
          apiKey = config.age.secrets."universe/wakatime/api_key";
        };
        script =
          { decrypt, deps, ... }:
          ''
            api_key="$(${decrypt} "${deps.apiKey.file}")"

            cat <<EOF
            [settings]
            api_url = https://waka.${domain}/api
            api_key = $api_key
            EOF
          '';
      };
      path = "/home/${user.name}/.wakatime.cfg";
      owner = user.name;
      symlink = false;
    };
  };
}
