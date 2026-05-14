{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet) display;
  inherit (config.planet.programs) sioyek;
in
{
  options.planet.programs = {
    sioyek = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = display.enable;
        description = "Enable sioyek";
        example = "true";
      };
    };
  };

  config = lib.mkIf sioyek.enable {
    planet.hm = [
      {
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
