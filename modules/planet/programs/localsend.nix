{
  config,
  lib,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.programs) localsend;
in
{
  options.planet.programs.localsend = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = planet.desktop.enable;
      description = "Enable LocalSend.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open the firewall for LocalSend transfers.";
    };
  };

  config.programs.localsend = {
    inherit (localsend) enable openFirewall;
  };
}
