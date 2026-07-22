{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  options.planet.programs.herdr.package = lib.mkOption {
    type = lib.types.package;
    readOnly = true;
    default = inputs.herdr.packages.${system}.default;
    description = "Package used for Herdr.";
  };

  config.environment.systemPackages = [ planet.programs.herdr.package ];
}
