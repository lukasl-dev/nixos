{ config, pkgs, ... }:

let
  inherit (config.universe) user domain;
in
{
  environment.systemPackages = with pkgs; [ wakatime-cli ];

  sops = {
    secrets = {
      "universe/wakatime/api_key" = {
        owner = user.name;
      };
    };
    templates."universe/wakatime/cfg" = {
      path = "/home/${user.name}/.wakatime.cfg";
      owner = user.name;
      content =
        let
          inherit (config.sops) placeholder;
        in
        # toml
        ''
          [settings]
          api_url = https://waka.${domain}/api
          api_key = ${placeholder."universe/wakatime/api_key"}
        '';
    };
  };
}
