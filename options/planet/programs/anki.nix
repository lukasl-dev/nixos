{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.universe) user domain;

  inherit (config.planet.programs) anki;

  wrapAnki = pkg:
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

          package = wrapAnki pkgs.anki;

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
