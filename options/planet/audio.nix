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

      # extraConfig = {
      #   pipewire."10-clock-and-resample" = {
      #     "context.properties" = {
      #       "default.clock.rate" = 48000;
      #       "default.clock.allowed-rates" = [
      #         44100
      #         48000
      #         96000
      #       ];
      #       "default.clock.quantum" = 256;
      #       "default.clock.min-quantum" = 128;
      #       "default.clock.max-quantum" = 1024;
      #       "resample.quality" = 10;
      #     };
      #   };
      #
      #   pipewire-pulse."10-pulse-quality" = {
      #     "pulse.properties" = {
      #       "flat-volumes" = false;
      #     };
      #     "stream.properties" = {
      #       "resample.quality" = 10;
      #     };
      #   };
      # };

      # wireplumber.extraConfig = {
      #   "10-bluez-quality" = {
      #     "monitor.bluez.properties" = {
      #       "bluez5.enable-sbc-xq" = true;
      #       "bluez5.enable-msbc" = true;
      #       "bluez5.enable-hw-volume" = true;
      #     };
      #   };
      #
      #   "11-bluetooth-policy" = {
      #     "wireplumber.settings" = {
      #       "bluetooth.autoswitch-to-headset-profile" = false;
      #     };
      #   };
      #
      #   "99-disable-suspend" = {
      #     "monitor.alsa.rules" = [
      #       {
      #         matches = [
      #           { "node.name" = "~alsa_input.*"; }
      #           { "node.name" = "~alsa_output.*"; }
      #         ];
      #         actions = {
      #           "update-props" = {
      #             "session.suspend-timeout-seconds" = 0;
      #           };
      #         };
      #       }
      #     ];
      #   };
      #
      #   "20-focusrite-2i2" = {
      #     "monitor.alsa.rules" = [
      #       {
      #         matches = [
      #           {
      #             "node.name" = "~alsa_(input|output).usb-Focusrite_Scarlett_2i2_4th_Gen_.*";
      #           }
      #         ];
      #         actions = {
      #           "update-props" = {
      #             "audio.rate" = 48000;
      #             "audio.format" = "S32LE";
      #           };
      #         };
      #       }
      #       {
      #         matches = [
      #           {
      #             "node.name" = "~alsa_input.usb-Focusrite_Scarlett_2i2_4th_Gen_.*.HiFi__Mic1__source.*";
      #           }
      #         ];
      #         actions = {
      #           "update-props" = {
      #             "node.nick" = "Scarlett Mic 1 (M 70 PRO X)";
      #             "priority.session" = 2100;
      #           };
      #         };
      #       }
      #     ];
      #   };
      # };
    };

    services.libinput.enable = true;

    environment.systemPackages = [
      pkgs.helvum
      pkgs.pwvucontrol
      pkgs.easyeffects
    ];

    planet.wm.hyprland.bindings = [
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
}
