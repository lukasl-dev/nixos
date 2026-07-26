{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.programs) handy;
  inherit (pkgs.stdenv.hostPlatform) system;

  package = inputs.handy.packages.${system}.handy;
in
{
  options.planet.programs.handy.enable = lib.mkEnableOption "Handy" // {
    default = planet.desktop.enable;
    defaultText = lib.literalExpression "config.planet.desktop.enable";
  };

  config = lib.mkIf handy.enable {
    environment.systemPackages = [
      package
      pkgs.wtype
    ];

    planet.desktop.autoStart = lib.optionals planet.desktop.enable [
      "${lib.getExe package} --start-hidden"
    ];
  };
}
