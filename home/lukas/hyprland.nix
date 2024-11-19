{ inputs, pkgs, ... }:

let
  mainMod = "SUPER";
in
{
  imports = [ inputs.hyprland.homeManagerModules.default ];

  wayland.windowManager.hyprland = {
    enable = true;

    xwayland.enable = true;

    systemd = {
      enable = true;
      variables = [ "--all" ];
    };

    sourceFirst = true;

    settings = {
      # TODO: should depend on the host
      monitor = [
        "DP-3,1920x1080@240,0x0,1"
        "HDMI-A-1,1920x1080@75,1920x0,1"
        "Unknown-1,disable"
      ];

      # TODO: is all of that necessary?
      env = [
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORM,wayland"
        "NVD_BACKEND,direct"

        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"

        # hyprcursor
        "HYPRCURSOR_SIZE,26"
        "HYPRCURSOR_THEME,Catppuccin-Mocha-Light-Cursors"
      ];

      exec-once = [
        "wl-paste --type text --watch cliphist store"

        "zapzap"
        "vesktop"
        "1password"
        "localsend_app"

        "waybar"
      ];

      bind = [
        "${mainMod}, Space, exec, rofi -show drun -show-icons"
        "${mainMod}, Backspace, exec, rofi -show drun -show-icons"
        "${mainMod}, E, exec, bemoji"
        "${mainMod}, C, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"

        "${mainMod}, p, exec, swaync-client -t"

        "${mainMod}, S, exec, hyprshot -m region --clipboard-only"

        ''${mainMod}, T, exec, kitty --hold zsh -c "tmux attach-session || tmux new-session"''

        "${mainMod}, B, exec, brave"
        # "${mainMod}, B, exec, zen-bin"

        "${mainMod}, I, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        "${mainMod}, O, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

        "${mainMod}, Q, togglespecialworkspace,"
        "${mainMod} SHIFT, Q, movetoworkspace, special"

        "${mainMod}, V, togglefloating,"
        "${mainMod}, V, centerwindow,"

        "${mainMod}, N, swapnext,"
        "${mainMod}, W, killactive,"

        "${mainMod}, M, fullscreen, 1"
        "${mainMod} SHIFT, M, fullscreen,"

        "${mainMod}, h, movefocus, l"
        "${mainMod}, l, movefocus, r"
        "${mainMod}, k, movefocus, u"
        "${mainMod}, j, movefocus, d"

        "${mainMod}, 1, workspace, 1"
        "${mainMod}, 2, workspace, 2"
        "${mainMod}, 3, workspace, 3"
        "${mainMod}, 4, workspace, 4"
        "${mainMod}, 5, workspace, 5"
        "${mainMod}, 6, workspace, 6"
        "${mainMod}, 7, workspace, 7"
        "${mainMod}, 8, workspace, 8"
        "${mainMod}, 9, workspace, 9"
        "${mainMod}, 0, workspace, 10"

        "${mainMod} SHIFT, 1, movetoworkspace, 1"
        "${mainMod} SHIFT, 2, movetoworkspace, 2"
        "${mainMod} SHIFT, 3, movetoworkspace, 3"
        "${mainMod} SHIFT, 4, movetoworkspace, 4"
        "${mainMod} SHIFT, 5, movetoworkspace, 5"
        "${mainMod} SHIFT, 6, movetoworkspace, 6"
        "${mainMod} SHIFT, 7, movetoworkspace, 7"
        "${mainMod} SHIFT, 8, movetoworkspace, 8"
        "${mainMod} SHIFT, 9, movetoworkspace, 9"
        "${mainMod} SHIFT, 0, movetoworkspace, 10"

        "${mainMod}, mouse_down, workspace, e+1"
        "${mainMod}, mouse_up, workspace, e-1"
      ];

      bindm = [
        "${mainMod}, mouse:272, movewindow"
        "${mainMod}, mouse:273, resizewindow"
      ];

      windowrule = [ ];

      windowrulev2 = [
        "float,title:(Picture-in-picture)"
        "float,title:(Picture-in-Picture)"
        "float,class:(Rofi)"
        "float,class:(1Password)"
        "float,title:(Save File)"
        "float,title:(Open File)"
        # "float,initialTitle:(discord popout)"

        # "workspace 1,initialClass:(vesktop)"

        "workspace 1,initialTitle:(YouTube Music)"
        "noanim,initialClass:^(Minecraft\*\s1\.20\.6)$"
        "noblur,initialClass:^(Minecraft\*\s1\.20\.6)$"

        # "pin,title:(.*)is sharing your screen(.*)"
        # "move 100%-w-35% 0%,title:(.*)is sharing your screen(.*)"
        # "bordersize 0,title:(.*)is sharing your screen(.*)"
      ];

      input = {
        kb_layout = "us";
        kb_variant = ",qwerty";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = "no";
        };
        sensitivity = 0;
      };

      general = {
        gaps_in = 5;
        gaps_out = 30;
        border_size = 2;

        "col.active_border" = "$mauve $lavender 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        layout = "dwindle";
      };

      decoration = {
        rounding = 10;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      animations = {
        enabled = "yes";

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };

      gestures = {
        workspace_swipe = "off";
      };

      misc = {
        force_default_wallpaper = 0;
        vrr = 2;
      };
    };
  };

  # xdg
  xdg.portal = {
    enable = true;
    config = {
      hyprland.default = [
        "gtk"
        "hyprland"
      ];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    xdgOpenUsePortal = true;
  };

  services.hyprpaper = {
    enable = true;

    settings = {
      ipc = "on";
      splash = false;
      splash_offset = 2.0;

      preload = [ "~/nixos/wallpapers/10.png" ];
      wallpaper = [ ",~/nixos/wallpapers/10.png" ];
    };
  };

  # waybar
  programs.waybar = {
    enable = true;

    style = builtins.readFile ../../dots/waybar/style.css;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";

        modules-left = [
          "temperature"
          "memory"
          "cpu"
          "custom/nvidia"
          "custom/uxplay"
        ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right = [
          "custom/mic"
          "wireplumber"
          "clock"
          "custom/notification"
          "tray"
        ];

        tray = {
          icon-size = 21;
          spacing = 10;
        };

        cpu = {
          format = "   {usage}%";
          interval = 1;
          on-click = "kitty -e btop";
        };

        "custom/nvidia" = {
          format = "  {}%";
          escape = true;
          interval = 1;
          tooltip = false;
          exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits";
          on-click = "kitty -e btop";
          max-length = 50;
        };

        "custom/uxplay" = {
          format = "{}";
          exec = "if pgrep uxplay > /dev/null; then echo ''; else echo ''; fi";
          interval = 1;
          on-click = "if pgrep uxplay > /dev/null; then pkill -f uxplay; else uxplay -p tcp 4000 -p udp 5000; fi";
        };

        temperature = {
          format = "  {temperatureC} °C";
          interval = 1;
          on-click = "kitty -e btop";
        };

        memory = {
          format = "   {}%";
          interval = 1;
          on-click = "kitty -e btop";
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          sort-by-number = true;
        };

        "custom/mic" = {
          format = "{}";
          escape = true;
          interval = 1;
          tooltip = false;
          exec = ''
            wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print ($NF == "[MUTED]") ? " " : "  " int($2*100)"%"}'
          '';
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          max-length = 50;
        };

        "custom/notification" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
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

        clock = {
          timezone = "Europe/Vienna";
          format = " {:%d/%m/%Y %H:%M}";
        };
      };
    };
  };

  # quick access
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
  };

  # notifications
  services.swaync = {
    enable = true;
    style = builtins.readFile ../../dots/swaync/theme.css;
  };

  # auto mount removable drives
  services.udiskie.enable = true;
  # TODO: should this be enabled for non-hyprland?

  # hyprcursor icons directory
  home.file.".icons" = {
    enable = true;
    source = "${pkgs.catppuccin-cursors.mochaLight}/share/icons/";
    target = ".icons";
  };

  home.packages = [
    # emoji quick access
    pkgs.bemoji

    # waybar
    pkgs.waybar

    # notifications
    pkgs.libnotify

    # screenshot
    pkgs.grim
    pkgs.hyprshot

    # clipboard
    pkgs.wl-clipboard
    pkgs.cliphist

    # hyprcursor
    pkgs.hyprcursor
    pkgs.catppuccin-cursors.mochaMauve

    # miscellaneous
    pkgs.xwaylandvideobridge
    pkgs.xdg-utils
  ];
}
