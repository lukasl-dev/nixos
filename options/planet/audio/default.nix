{
  config,
  lib,
  pkgs,
  ...
}:

let
  audio = config.planet.audio;
in
{
  options.planet.audio = {
    enable = lib.mkEnableOption "Enable pipewire";
  };

  config = lib.mkIf audio.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };

      pulse.enable = true;
      jack.enable = true;

      extraConfig.pipewire = {
        "context.properties" = {
          "default.clock.min-quantum" = 2048;
          "default.clock.quantum-limit" = 8192;
        };
      };
    };

    services.libinput.enable = true;
    environment.systemPackages = [ pkgs.helvum ];
  };
}
