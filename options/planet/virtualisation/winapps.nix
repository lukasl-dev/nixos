{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;

  winapps = config.planet.virtualisation.winapps;
in
{
  options.planet.virtualisation.winapps = {
    enable = lib.mkEnableOption "Enable winapps";
  };

  config = lib.mkIf winapps.enable {
    environment.systemPackages = [
      inputs.winapps.packages."${system}".winapps
      inputs.winapps.packages."${system}".winapps-launcher # optional

      pkgs.dialog
      pkgs.freerdp
    ];
  };

  # TODO: /home/lukas/.local/bin
}
