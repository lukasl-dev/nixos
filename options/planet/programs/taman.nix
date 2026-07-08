{
  self,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) display;
  inherit (config.planet.programs) taman;
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  options.planet.programs.taman = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = display.enable;
      description = "Enable taman, a TUI Pomodoro app that grows plants";
    };

    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = self.packages.${system}.taman;
      description = "Package used for taman.";
    };
  };

  config = lib.mkIf taman.enable {
    environment.systemPackages = [ taman.package ];
  };
}
