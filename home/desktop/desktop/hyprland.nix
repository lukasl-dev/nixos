{
  meta,
  inputs,
  ...
}:

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

        "ELECTRON_OZONE_PLATFORM_HINT,auto"

        # hyprcursor
        "HYPRCURSOR_SIZE,26"
        "HYPRCURSOR_THEME,Catppuccin-Mocha-Light-Cursors"
      ];

      exec-once = [
        "systemctl --user start hyprpolkitagent"
        "wl-paste --type text --watch cliphist store"

        "zapzap"
        "vesktop"
        "1password"
        "bitwarden"
        "localsend_app"

        "waybar"
      ];

      cursor = {
        no_hardware_cursors = true;
      };

      bind = [
        "${mainMod}, Space, exec, rofi -show drun -show-icons"
        "${mainMod}, Backspace, exec, rofi -show drun -show-icons"
        "${mainMod}, E, exec, bemoji"
        "${mainMod}, C, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"

        "${mainMod}, p, exec, swaync-client -t"

        "${mainMod}, S, exec, hyprshot -m region --clipboard-only"

        "${mainMod}, T, exec, ghostty"

        "${mainMod}, B, exec, brave"

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
        # for right-hand usage
        "${mainMod}, mouse:272, movewindow"
        "${mainMod}, mouse:273, resizewindow"

        # for left-hand usage
        "ALT, mouse:272, movewindow"
        "ALT, mouse:273, resizewindow"
      ];

      windowrule = [ ];

      windowrulev2 = [
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

        # ========= ========= ========= ========= ========= =========
        # Vesktop
        # ========= ========= ========= ========= ========= =========

        # Desktop App
        "workspace 1,initialClass:(vesktop)"

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
      ];

      input = {
        kb_layout = "us";
        kb_variant = ",qwerty";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = "yes";
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
    };
  };
}
