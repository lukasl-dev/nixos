{ meta, pkgs, ... }:

{
  programs.waybar = {
    enable = true;

    style = builtins.readFile ../../../dots/waybar/style.css;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        mod = "dock";
        exclusive = true;
        passtrough = false;
        gtk-layer-shell = true;
        height = 32;

        modules-left = [
          "clock"
          "hyprland/workspaces"
        ];

        modules-center = [ ];

        modules-right = [
          "tray"
          "network"
          "bluetooth"
          "custom/mic"
          "wireplumber"
          "battery"
          "custom/uxplay"
        ];

        "hyprland/window" = {
          format = "{}";
        };

        "hyprland/workspaces" = {
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
          all-outputs = true;
          on-click = "activate";
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
          };
        };

        "custom/uxplay" = {
          format = "{}";
          exec = "if pgrep uxplay > /dev/null; then echo ''; else echo ''; fi";
          interval = 1;
          on-click = "if pgrep uxplay > /dev/null; then pkill -f uxplay; else uxplay -p tcp 4000 -p udp 5000; fi";
        };

        "custom/mic" = {
          format = "{}";
          escape = true;
          interval = 1;
          tooltip = false;
          exec = ''
            wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print ($NF == "[MUTED]") ? " " : " " int($2*100)"%"}'
          '';
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          max-length = 50;
        };

        wireplumber = {
          format = "{icon} {volume}%";
          format-muted = " ";
          format-icons = {
            default = [
              ""
              ""
              " "
            ];
          };
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };

        tray = {
          icon-size = 18;
          tooltip = false;
          spacing = 12;
        };

        clock = {
          timezone = meta.time.zone;
          format = "{:%d/%m/%Y %H:%M}";
        };

        network = {
          format-wifi = "  {essid} {signalStrength}%";
          format-ethernet = "󰈀";
          format-disconnected = "󰈂";
        };

        bluetooth = {
          format-bluetooth = " {status}";
          format-connected = " {num_connections}";
          format-disconnected = "";
          format-disabled = "";
        };

        battery = {
          states = {
            warning = 20;
            critical = 15;
          };
          format = "󰁹 {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰂄 {capacity}%";
        };
      };
    };
  };

  home.packages = with pkgs; [
    waybar
  ];
}
