{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.programs) discord;
  inherit (planet.networking) mullvad;

  basePackage = pkgs.vesktop;

  excludedLauncher = pkgs.writeShellScriptBin "vesktop" ''
    exec ${config.security.wrapperDir}/mullvad-exclude \
      ${lib.getExe basePackage} "$@"
  '';

  excludedPackage = pkgs.symlinkJoin {
    name = "vesktop-mullvad-excluded";
    paths = [ basePackage ];

    postBuild = ''
      rm "$out/bin/vesktop"
      ln -s ${lib.getExe excludedLauncher} "$out/bin/vesktop"
    '';

    inherit (basePackage) meta;
  };
in
{
  options.planet.programs.discord = {
    enable = lib.mkEnableOption "Discord" // {
      default = planet.desktop.enable;
      defaultText = lib.literalExpression "config.planet.desktop.enable";
    };
  };

  config = lib.mkIf discord.enable {
    environment.systemPackages = [
      (if mullvad.enable then excludedPackage else basePackage)
    ];
  };
}
