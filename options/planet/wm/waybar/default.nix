{ config, lib, ... }:

let
  planet = config.planet;
  hyprland = planet.wm.hyprland;

  waybar = planet.wm.waybar;
in
{
  options.planet.wm.waybar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = hyprland.enable;
      description = "Enable Waybar for Hyprland";
    };
  };

  config = lib.mkIf waybar.enable {
    universe.hm = [
      {
        programs.waybar = {
          enable = true;

          style = builtins.readFile ./style.css;

          settings = {
            mainBar = {
              layer = "top";
              position = "top";
              mod = "dock";
              exclusive = true;
              passthrough = false;
              gtk-layer-shell = true;
              height = 32;

              modules-left = [
                "hyprland/workspaces"
              ];

              modules-center = [
                "hyprland/window"
              ];

              modules-right = builtins.concatLists [
                [
                  "privacy"
                  "wireplumber"
                  "custom/mic"
                  "network"
                  "bluetooth"
                  "battery"
                  "tray"
                  "clock"
                ]
                (lib.optionals (config.planet.programs.uxplay.enable) [
                  "custom/uxplay"
                ])
              ];

              "hyprland/window" = {
                format = "{}";
                max-length = 80;
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

              "custom/uxplay" = lib.mkIf config.planet.programs.uxplay.enable {
                format = "{}";
                exec = "if pgrep uxplay > /dev/null; then echo ''; else echo ''; fi";
                interval = 1;
                on-click = "if pgrep uxplay > /dev/null; then pkill -f uxplay; else uxplay -p tcp 4000 -p udp 5000; fi";
              };

              "custom/mic" = {
                return-type = "json";
                interval = 1;
                tooltip = false;
                exec = ''
                  status=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
                  vol=$(echo "$status" | awk '{print int($2*100)}')
                  if echo "$status" | grep -q "\[MUTED\]"; then
                    echo '{"text":"","class":"muted"}'
                  else
                    echo "{\"text\":\" $vol%\",\"class\":\"unmuted\"}"
                  fi
                '';
                on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
                max-length = 50;
              };

              wireplumber = {
                format = "{icon}   {volume}%";
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
                icon-size = 16;
                tooltip = false;
                spacing = 8;
              };

              clock = {
                timezone = planet.timeZone;
                format = "{:%a %d/%m %H:%M}";
                tooltip-format = "{:%A, %B %d • %Y}";
              };

              network = {
                format-wifi = "    {signalStrength}%";
                format-ethernet = "󰈀";
                format-disconnected = "󰈂";
              };

              bluetooth = {
                format-bluetooth = " {status}";
                format-connected = " {num_connections}";
                format-disconnected = "";
                format-disabled = "";
              };

              privacy = {
                "icon-spacing" = 4;
                "icon-size" = 18;
                "transition-duration" = 250;
                modules = [
                  { type = "screenshare"; tooltip = true; "tooltip-icon-size" = 24; }
                  { type = "audio-out";  tooltip = true; "tooltip-icon-size" = 24; }
                  { type = "audio-in";   tooltip = true; "tooltip-icon-size" = 24; }
                ];
                "ignore-monitor" = true;
                ignore = [
                  { type = "audio-in"; name = "cava"; }
                  { type = "screenshare"; name = "obs"; }
                ];
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
      }
    ];
  };
}
