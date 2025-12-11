{
  inputs,
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
  hypr-nixpkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};

  hypr-pkgs = inputs.hyprland.packages.${system};
  inherit (hypr-pkgs) hyprland xdg-desktop-portal-hyprland;
in
{
  options.planet.wm.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland";

    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "eDP-1" ];
      description = "List of monitors to use with Hyprland. Use the output of 'hyprctl monitors' to get the correct names.";
    };
  };

  config = lib.mkIf config.planet.wm.hyprland.enable {
    security.polkit.enable = true;
    # TODO: update and enable this:
    # services.hyprpolkitagent.enable = true;

    environment = {
      sessionVariables = {
        # hint electron apps to use ozone wayland platform
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";

        # prefer wayland over X11 for GTK apps
        GDK_BACKEND = "wayland,x11";

        # prefer wayland over xcb for QT apps
        QT_QPA_PLATFORM = "wayland;xcb";

        # fix reparenting issues with Java apps
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };
    };

    universe.hm = [
      {
        wayland.windowManager.hyprland = {
          settings =
            let
              mainMod = "SUPER";
              windowBinding = s: [
                "${mainMod} ${s}"
                "ALT ${s}"
              ];
            in
            {
              env = [
                "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
                "QT_QPA_PLATFORM,wayland"
                "NVD_BACKEND,direct"

                "XDG_CURRENT_DESKTOP,Hyprland"
                "XDG_SESSION_TYPE,wayland"
                "ELECTRON_OZONE_PLATFORM_HINT,auto"
              ];

              bind = builtins.concatLists [
                [
                  "${mainMod}, p, exec, obsidian"
                  ''${mainMod}, S, exec, grim -g "$(slurp -d)" - | wl-copy''
                  "${mainMod}, T, exec, ghostty"
                  "${mainMod}, B, exec, zen-beta"
                  # "${mainMod}, G, exec, waybar-toggle"

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

                "renderunfocused, initialClass:(steam_app_2622380)"

                # ========= ========= ========= ========= ========= =========
                # Obsidian
                # ========= ========= ========= ========= ========= =========
                "workspace 10,initialClass:(obsidian)"
                # "noinitialfocus,initialClass:(obsidian)"

                # ========= ========= ========= ========= ========= =========
                # Zen
                # ========= ========= ========= ========= ========= =========
                "float,initialClass:(zen-beta),title:^(Extension:.*)$"
                "center,initialClass:(zen-beta),title:^(Extension:.*)$"
                "size 524 706,initialClass:(zen-beta),title:^(Extension:.*)$"

                # ========= ========= ========= ========= ========= =========
                # Mullvad VPN
                # ========= ========= ========= ========= ========= =========
                "float,initialTitle:(Mullvad VPN)"
                "pin,initialTitle:(Mullvad VPN)"
              ];
            };
        };

        # cursor icons
        home.file.".icons" = {
          enable = true;
          source = "${pkgs.catppuccin-cursors.mochaLight}/share/icons/";
          target = ".icons";
        };

        # wallpapers
        # services.wpaperd = {
        #   enable = true;
        #   settings = {
        #     default = {
        #       duration = "5m";
        #       mode = "center";
        #       sorting = "random";
        #     };
        #     any = {
        #       path = ../../../wallpapers;
        #     };
        #   };
        # };

        # notification manager
        # services.swaync.enable = true;
        # home.packages = [ pkgs.libnotify ];

        # TODO: make this configurable
        # dimming
        services.wlsunset = {
          enable = true;

          latitude = 48.2081;
          longitude = 16.3713;

          temperature = {
            day = 6500;
            night = 4500;
          };
        };
      }
    ];
  };
}
