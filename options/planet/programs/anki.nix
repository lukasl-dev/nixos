{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.universe) user domain;

  inherit (config.planet.programs) anki;
in
{
  options.planet.programs.anki = {
    enable = lib.mkEnableOption "Enable Anki";
  };

  config = lib.mkIf anki.enable {
    sops.secrets = {
      "universe/anki/username" = {
        owner = user.name;
      };
      "universe/anki/key" = {
        owner = user.name;
      };
    };

    universe.hm = [
      {
        programs.anki = {
          enable = true;

          addons = with pkgs; [ ankiAddons.anki-connect ];

          sync = {
            autoSync = true;
            url = "https://anki.${domain}";
            usernameFile = config.sops.secrets."universe/anki/username".path;
            keyFile = config.sops.secrets."universe/anki/key".path;
          };
        };
      }
    ];
  };
}
