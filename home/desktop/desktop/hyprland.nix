{
  meta,
  config,
  lib,
  pkgs-unstable,
  inputs,
  ...
}:

let
  mainMod = "SUPER";

  # window bindings should be triggerable with main mod and alt respectively
  windowBinding = s: [
    "${mainMod} ${s}"
    "ALT ${s}"
  ];

  rofi = config.programs.rofi.enable;
  swaync = config.services.swaync.enable;
in
{
  imports = [ inputs.hyprland.homeManagerModules.default ];

  wayland.windowManager.hyprland = {
    enable = true;

    package = inputs.hyprland.packages.${pkgs-unstable.stdenv.hostPlatform.system}.hyprland;

    sourceFirst = true;

    xwayland.enable = true;

    systemd = {
      enable = true;
      variables = [ "--all" ];
    };

    settings = {
      monitor = meta.hypr.monitors ++ [
        "Unknown-1,disable"
      ];

      # TODO: is all of that necessary?
      env = [
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORM,wayland"
        "NVD_BACKEND,direct"

        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        #
        "ELECTRON_OZONE_PLATFORM_HINT,auto"

        # # hyprcursor
        # "HYPRCURSOR_SIZE,26"
        # "HYPRCURSOR_THEME,Catppuccin-Mocha-Light-Cursors"
      ];

      exec-once = [
        "systemctl --user start hyprpolkitagent"
        "clipse --listen"
        "wpaperd -d"

        "vesktop"
        "bitwarden"
        "localsend_app"

        "waybar"
      ];

      cursor = {
        no_hardware_cursors = true;
      };

      bind = builtins.concatLists [
        [
          (lib.mkIf rofi "${mainMod}, Space, exec, rofi -show drun -show-icons")
          (lib.mkIf rofi "${mainMod}, Backspace, exec, rofi -show drun -show-icons")
          (lib.mkIf rofi "${mainMod}, E, exec, bemoji")

          ''${mainMod}, C, exec, ghostty --class="clipse.clipse" --command="clipse"''

          (lib.mkIf swaync "${mainMod}, p, exec, swaync-client -t")

          ''${mainMod}, S, exec, grim -g "$(slurp -d)" - | wl-copy''

          "${mainMod}, T, exec, ghostty"

          "${mainMod}, B, exec, brave"

          "${mainMod}, I, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          "${mainMod}, O, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

          "${mainMod}, Q, togglespecialworkspace,"
          "${mainMod} SHIFT, Q, movetoworkspace, special"
        ]

        (windowBinding ", V, togglefloating")
        (windowBinding ", V, centerwindow")

        (windowBinding ", R, togglesplit")
        (windowBinding ", N, swapsplit")
        (windowBinding ", F, pseudo")

        (windowBinding ", W, killactive,")

        (windowBinding ", M, fullscreen, 1")
        (windowBinding "SHIFT, M, fullscreen,")

        (windowBinding ", h, movefocus, l")
        (windowBinding ", l, movefocus, r")
        (windowBinding ", k, movefocus, u")
        (windowBinding ", j, movefocus, d")

        (windowBinding ", 1, workspace, 1")
        (windowBinding ", 2, workspace, 2")
        (windowBinding ", 3, workspace, 3")
        (windowBinding ", 4, workspace, 4")
        (windowBinding ", 5, workspace, 5")
        (windowBinding ", 6, workspace, 6")
        (windowBinding ", 7, workspace, 7")
        (windowBinding ", 8, workspace, 8")
        (windowBinding ", 9, workspace, 9")
        (windowBinding ", 0, workspace, 10")

        (windowBinding "SHIFT, 1, movetoworkspace, 1")
        (windowBinding "SHIFT, 2, movetoworkspace, 2")
        (windowBinding "SHIFT, 3, movetoworkspace, 3")
        (windowBinding "SHIFT, 4, movetoworkspace, 4")
        (windowBinding "SHIFT, 5, movetoworkspace, 5")
        (windowBinding "SHIFT, 6, movetoworkspace, 6")
        (windowBinding "SHIFT, 7, movetoworkspace, 7")
        (windowBinding "SHIFT, 8, movetoworkspace, 8")
        (windowBinding "SHIFT, 9, movetoworkspace, 9")
        (windowBinding "SHIFT, 0, movetoworkspace, 10")

        (windowBinding ", mouse_down, workspace, e+1")
        (windowBinding ", mouse_up, workspace, e-1")
      ];

      bindm = builtins.concatLists [
        (windowBinding ", mouse:272, movewindow")
        (windowBinding ", mouse:273, resizewindow")
      ];

      windowrulev2 = [
        # ========= ========= ========= ========= ========= =========
        # Clipse
        # ========= ========= ========= ========= ========= =========

        "float,class:(clipse.clipse)"
        "center,class:(clipse.clipse)"
        "size 622 652,class:(clipse.clipse)"

        # ========= ========= ========= ========= ========= =========
        # 1Password
        # ========= ========= ========= ========= ========= =========

        "float,class:(1Password)"
        "center,class:(1Password)"
        "opacity 0.8,class:(1Password)"
        "size 1309 783,class:(1Password)"

        # ========= ========= ========= ========= ========= =========
        # Bitwarden
        # ========= ========= ========= ========= ========= =========

        # Desktop App
        "float,title:(Bitwarden)"
        "center,title:(Bitwarden)"
        "opacity 0.8,title:(Bitwarden)"
        "size 1309 783,title:(Bitwarden)"

        # Bitwarden Brave Popups
        "float,initialClass:(brave-nngceckbapebfimnlniiiahkandclblb-Default)"
        "center,initialClass:(brave-nngceckbapebfimnlniiiahkandclblb-Default)"
        "opacity 0.8,initialClass:(brave-nngceckbapebfimnlniiiahkandclblb-Default)"
        "size 581 783,initialClass:(brave-nngceckbapebfimnlniiiahkandclblb-Default)"

        # Bitwarden Vivaldi Popups
        "float,initialTitle:(Bitwarden - Vivaldi)"
        "center,initialTitle:(Bitwarden - Vivaldi)"
        "opacity 0.8,initialTitle:(Bitwarden - Vivaldi)"
        "size 581 783,initialTitle:(Bitwarden - Vivaldi)"

        # ========= ========= ========= ========= ========= =========
        # Brave
        # ========= ========= ========= ========= ========= =========

        "float,center,title:(Sign in – Google accounts - Brave)"

        # ========= ========= ========= ========= ========= =========
        # Vesktop
        # ========= ========= ========= ========= ========= =========

        # Desktop App
        "workspace 1,initialClass:(vesktop)"
        "noinitialfocus,initialClass:(vesktop)"

        # File Download
        "float,initialTitle:(https://discord.com/*)"
        "pin,initialTitle:(https://discord.com/*)"
        "opacity 0.8,initialTitle:(https://discord.com/*)"
        "center 1,initialTitle:(https://discord.com/*)"
        "size 934 489,initialTitle:(https://discord.com/*)"

        # ========= ========= ========= ========= ========= =========
        # Minecraft
        # ========= ========= ========= ========= ========= =========

        "noanim,initialClass:^(Minecraft\*\s1\.20\.6)$"
        "noblur,initialClass:^(Minecraft\*\s1\.20\.6)$"

        # ========= ========= ========= ========= ========= =========
        # Picture-in-picture (PiP)
        # ========= ========= ========= ========= ========= =========

        "float,initialTitle:(Picture-in-picture)"
        "pin,initialTitle:(Picture-in-picture)"

        "float,initialTitle:(Picture-in-Picture)"
        "pin,initialTitle:(Picture-in-Picture)"

        "float,initialTitle:(Picture in picture)"
        "pin,initialTitle:(Picture in picture)"

        # ========= ========= ========= ========= ========= =========
        # YouTube Music
        # ========= ========= ========= ========= ========= =========

        "workspace 1,initialClass:(YouTube.Music)"

        # ========= ========= ========= ========= ========= =========
        # XDG Desktop Portal
        # ========= ========= ========= ========= ========= =========

        "float,initialClass:(xdg-desktop-portal-gtk)"
        "pin,initialClass:(xdg-desktop-portal-gtk)"
        "opacity 0.8,initialClass:(xdg-desktop-portal-gtk)"
        "center 1,initialClass:(xdg-desktop-portal-gtk)"
        "size 934 489,initialClass:(xdg-desktop-portal-gtk)"

        # ========= ========= ========= ========= ========= =========
        # Steam
        # ========= ========= ========= ========= ========= =========

        # Friend List
        "float,initialClass:(steam),initialTitle:(Friends List)"
        "center,initialClass:(steam),initialTitle:(Friends List)"
        "size 524 706,initialClass:(steam),initialTitle:(Friends List)"

        # ========= ========= ========= ========= ========= =========
        # LocalSend
        # ========= ========= ========= ========= ========= =========

        "workspace 10, initialClass:(localsend_app)"
        "noinitialfocus, initialClass:(localsend_app)"
      ];

      input = {
        kb_layout = "us";
        kb_variant = ",qwerty";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = "yes";
        };
        sensitivity = 0;

        repeat_rate = 25;
        repeat_delay = 600;
      };

      general = {
        gaps_in = 5;
        gaps_out = 30;
        border_size = 2;

        "col.active_border" = "$mauve $lavender 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        layout = "dwindle";

        allow_tearing = false;
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
        mouse_move_enables_dpms = false;
        vrr = 1;
      };

      render = {
        direct_scanout = 1;
      };

      debug = {
        disable_logs = false;
      };
    };
  };
}
