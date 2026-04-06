{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) wm;
  inherit (config.planet) audio;
in
{
  options.planet.audio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable pipewire";
    };
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
      wireplumber.enable = true;

      extraConfig = {
        pipewire."10-clock-and-resample" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.allowed-rates" = [ 48000 ];
            "default.clock.quantum" = 1024;
            "default.clock.min-quantum" = 512;
            "default.clock.max-quantum" = 2048;
            "resample.quality" = 4;
          };
        };

        pipewire-pulse."10-pulse-quality" = {
          "pulse.properties" = {
            "flat-volumes" = false;
          };
          "stream.properties" = {
            "resample.quality" = 4;
          };
        };
      };

      wireplumber.extraConfig = {
        "99-disable-suspend" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                { "node.name" = "~alsa_input.*"; }
                { "node.name" = "~alsa_output.*"; }
              ];
              actions = {
                "update-props" = {
                  "session.suspend-timeout-seconds" = 0;
                };
              };
            }
          ];
        };
      };
    };

    services.libinput.enable = true;

    environment.systemPackages = with pkgs; [
      helvum
      pwvucontrol
      easyeffects
    ];

    planet.wm.hyprland = {
      launch = [ "easyeffects --service-mode" ];

      bindings = [
        {
          type = "exec";
          keys = [ "I" ];
          command = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        }
        {
          type = "exec";
          keys = [ "O" ];
          command = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        }
      ];
    };
  };
}
