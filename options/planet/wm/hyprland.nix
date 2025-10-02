{
  inputs,
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  hypr-nixpkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};
  hypr-pkgs = inputs.hyprland.packages.${system};
  hyprland = hypr-pkgs.hyprland;
  xdg-desktop-portal-hyprland = hypr-pkgs.xdg-desktop-portal-hyprland;
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
    nix.settings = {
      substituters = [
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    security.polkit.enable = true;
    # TODO: update and enable this:
    # services.hyprpolkitagent.enable = true;

    programs.hyprland = {
      enable = true;

      package = hyprland;
      portalPackage = xdg-desktop-portal-hyprland;

      xwayland.enable = true;
      withUWSM = false;
    };

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

      systemPackages = [
        pkgs-unstable.hyprpicker

        pkgs-unstable.egl-wayland
        pkgs-unstable.wl-clipboard

        pkgs-unstable.hyprcursor
        pkgs.catppuccin-cursors.mochaMauve

        pkgs.grim
        pkgs.slurp
        pkgs.hyprshot

        (pkgs.writeShellApplication {
          name = "waybar-toggle";
          runtimeInputs = [
            pkgs.waybar
            pkgs.procps
          ];
          text = ''
            PID_FILE="/tmp/waybar.pid"
            if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" > /dev/null; then
                kill "$(cat "$PID_FILE")"
                rm "$PID_FILE"
            else
                waybar &> /dev/null & echo $! > "$PID_FILE"
            fi
          '';
        })
      ];
    };

    hardware.graphics = {
      enable = true;
      package = hypr-nixpkgs.mesa;

      enable32Bit = true;
      package32 = hypr-nixpkgs.pkgsi686Linux.mesa;

      extraPackages = [ hypr-nixpkgs.rocmPackages.clr ];
    };

    universe.hm = [
      {
        imports = [ inputs.hyprland.homeManagerModules.default ];

        # hyprland settings
        wayland.windowManager.hyprland = {
          enable = true;
          package = hyprland;

          sourceFirst = true;
          xwayland.enable = true;
          systemd = {
            enable = true;
            variables = [ "--all" ];
          };

          settings =
            let
              mainMod = "SUPER";
              windowBinding = s: [
                "${mainMod} ${s}"
                "ALT ${s}"
              ];
            in
            {
              monitor = config.planet.wm.hyprland.monitors ++ [
                "Unknown-1,disable"
              ];

              env = [
                "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
                "QT_QPA_PLATFORM,wayland"
                "NVD_BACKEND,direct"

                "XDG_CURRENT_DESKTOP,Hyprland"
                "XDG_SESSION_TYPE,wayland"
                "ELECTRON_OZONE_PLATFORM_HINT,auto"

                "HYPRCURSOR_SIZE,26"
                "HYPRCURSOR_THEME,Catppuccin-Mocha-Light-Cursors"
              ];

              exec-once = builtins.concatLists [
                [
                  "systemctl --user start hyprpolkitagent"

                  # https://discourse.nixos.org/t/keyctl-read-alloc-permission-denied/8667/4
                  "keyctl link @u @s"

                  # TODO: only start these if the corresponding service is enabled
                  "clipse --listen"
                  "wpaperd -d"
                  "vesktop"
                  "element-desktop"
                  "bitwarden"
                  "mullvad-vpn"
                  "waybar-toggle"
                ]
              ];

              bind = builtins.concatLists [
                [
                  "${mainMod}, Space, exec, rofi -show drun -show-icons"
                  "${mainMod}, Backspace, exec, rofi -show drun -show-icons"
                  "${mainMod}, E, exec, bemoji"
                  ''${mainMod}, C, exec, ghostty --class="clipse.clipse" --command="clipse"''
                  "${mainMod}, p, exec, swaync-client -t"
                  ''${mainMod}, S, exec, grim -g "$(slurp -d)" - | wl-copy''
                  "${mainMod}, T, exec, ghostty"
                  "${mainMod}, B, exec, zen-beta"
                  "${mainMod}, G, exec, waybar-toggle"

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

                "renderunfocused, initialClass:(vesktop)"

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

              cursor = {
                no_hardware_cursors = true;
              };

              input = {
                kb_layout = "us";
                kb_variant = ",qwerty";
                follow_mouse = 1;
                touchpad = {
                  natural_scroll = "yes";
                };
                sensitivity = 0;

                repeat_rate = 25;
                repeat_delay = 200;
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
                enable_anr_dialog = false;
              };

              render = {
                direct_scanout = 1;
              };

              debug = {
                disable_logs = false;
              };
            };
        };

        # cursor icons
        home.file.".icons" = {
          enable = true;
          source = "${pkgs.catppuccin-cursors.mochaLight}/share/icons/";
          target = ".icons";
        };

        # wallpapers
        services.wpaperd = {
          enable = true;
          settings = {
            default = {
              duration = "5m";
              mode = "center";
              sorting = "random";
            };
            any = {
              path = ../../../wallpapers;
            };
          };
        };

        # notification manager
        services.swaync.enable = true;
        home.packages = [ pkgs.libnotify ];

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
