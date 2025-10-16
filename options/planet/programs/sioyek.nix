{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet) wm;

  inherit (config.planet.programs) sioyek;
in
{
  options.planet.programs.sioyek = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable sioyek";
      example = "true";
    };
  };

  config = lib.mkIf sioyek.enable {
    universe.hm = [
      {
        # catppuccin.sioyek.enable = false;
        programs.sioyek = {
          enable = true;
          package = pkgs.symlinkJoin {
            name = "sioyek";
            paths = [ pkgs.sioyek ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/sioyek \
                --set QT_QPA_PLATFORM xcb
            '';
          };
        };
      }
    ];
  };
}
