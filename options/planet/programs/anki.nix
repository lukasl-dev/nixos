{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet) domain;
  inherit (config.planet.programs) anki;

  wrapAnki =
    pkg:
    (pkgs.symlinkJoin {
      name = "${pkg.name or pkg.pname}-wrapped";
      paths = [ pkg ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/anki \
          --set QT_QPA_PLATFORM xcb \
          --set QTWEBENGINE_FORCE_USE_GBM 0 \
          --set QTWEBENGINE_CHROMIUM_FLAGS "--disable-gpu"
      '';
    })
    // {
      withAddons = addons: wrapAnki (pkg.withAddons addons);
    };
in
{
  options.planet.programs = {
    anki = {
      enable = lib.mkEnableOption "Enable Anki";

      url = lib.mkOption {
        type = lib.types.str;
        description = "anki sync url";
        default = "https://anki.${domain}";
      };

      username = lib.mkOption {
        type = lib.types.path;
        description = "username file";
      };

      key = lib.mkOption {
        type = lib.types.path;
        description = "key file";
      };
    };
  };

  config = lib.mkIf anki.enable {
    planet.hm = [
      {
        programs.anki = {
          enable = true;

          package = wrapAnki pkgs.anki;

          addons = with pkgs; [ ankiAddons.anki-connect ];

          profiles."User 1" = {
            sync = {
              autoSync = true;
              inherit (anki) url;
              usernameFile = anki.username;
              keyFile = anki.key;
            };
          };
        };
      }
    ];
  };
}
