{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
  hypr-nixpkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};
in
{
  imports = [ inputs.hyprland.nixosModules.default ];

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

      xwayland.enable = true;
      withUWSM = true;

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

          "$mauve" = "rgb(cba6f7)";
          "$lavender" = "rgb(b4befe)";

          env = [
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            "QT_QPA_PLATFORM,wayland"
            "NVD_BACKEND,direct"

            "XDG_CURRENT_DESKTOP,Hyprland"
            "XDG_SESSION_TYPE,wayland"
            "ELECTRON_OZONE_PLATFORM_HINT,auto"
          ];

          exec-once = builtins.concatLists [
            [
              "systemctl --user start hyprpolkitagent"

              # https://discourse.nixos.org/t/keyctl-read-alloc-permission-denied/8667/4
              "keyctl link @u @s"

              # TODO: only start these if the corresponding service is enabled
              # "wpaperd -d"
              "vesktop"
              "element-desktop"
              "bitwarden"
              "mullvad-vpn"
              # "waybar-toggle"
            ]
          ];

          bind = builtins.concatLists [
            [
              "${mainMod}, Space, exec, noctalia-shell ipc call launcher toggle"
              # "${mainMod}, Backspace, exec, rofi -show drun -show-icons"
              "${mainMod}, Backspace, exec, noctalia-shell ipc call launcher toggle"
              "${mainMod}, E, exec, bemoji"

              "${mainMod}, C, exec, noctalia-shell ipc call appLauncher toggleClipboard"
              # "${mainMod}, p, exec, swaync-client -t"
              "${mainMod}, p, exec, obsidian"
              ''${mainMod}, S, exec, grim -g "$(slurp -d)" - | wl-copy''
              "${mainMod}, T, exec, ghostty"
              "${mainMod}, B, exec, helium"
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

          windowrule = [
            # ========= ========= ========= ========= ========= =========
            # 1Password
            # ========= ========= ========= ========= ========= =========

            "float on, match:class 1Password"
            "center on, match:class 1Password"
            "opacity 0.8, match:class 1Password"
            "size 1309 783, match:class 1Password"

            # ========= ========= ========= ========= ========= =========
            # Bitwarden
            # ========= ========= ========= ========= ========= =========

            # Desktop App
            "float on, match:title Bitwarden"
            "center on, match:title Bitwarden"
            "opacity 0.8, match:title Bitwarden"
            "size 1309 783, match:title Bitwarden"

            # Bitwarden Brave Popups
            "float on, match:initial_class brave-nngceckbapebfimnlniiiahkandclblb-Default"
            "center on, match:initial_class brave-nngceckbapebfimnlniiiahkandclblb-Default"
            "opacity 0.8, match:initial_class brave-nngceckbapebfimnlniiiahkandclblb-Default"
            "size 581 783, match:initial_class brave-nngceckbapebfimnlniiiahkandclblb-Default"

            # Bitwarden Vivaldi Popups
            "float on, match:initial_title Bitwarden - Vivaldi"
            "center on, match:initial_title Bitwarden - Vivaldi"
            "opacity 0.8, match:initial_title Bitwarden - Vivaldi"
            "size 581 783, match:initial_title Bitwarden - Vivaldi"

            # ========= ========= ========= ========= ========= =========
            # Brave
            # ========= ========= ========= ========= ========= =========

            "float on, match:title Sign in – Google accounts - Brave"
            "center on, match:title Sign in – Google accounts - Brave"

            # ========= ========= ========= ========= ========= =========
            # Vesktop
            # ========= ========= ========= ========= ========= =========

            "render_unfocused on, match:initial_class vesktop"

            # Desktop App
            "workspace 1, match:initial_class vesktop"
            "no_initial_focus on, match:initial_class vesktop"

            # File Download
            "float on, match:initial_title https://discord.com/.*"
            "pin on, match:initial_title https://discord.com/.*"
            "opacity 0.8, match:initial_title https://discord.com/.*"
            "center on, match:initial_title https://discord.com/.*"
            "size 934 489, match:initial_title https://discord.com/.*"

            # ========= ========= ========= ========= ========= =========
            # Minecraft
            # ========= ========= ========= ========= ========= =========

            "no_anim on, match:initial_class ^Minecraft\\*\\s1\\.20\\.6$"
            "no_blur on, match:initial_class ^Minecraft\\*\\s1\\.20\\.6$"

            # ========= ========= ========= ========= ========= =========
            # Picture-in-picture (PiP)
            # ========= ========= ========= ========= ========= =========

            "float on, match:initial_title Picture-in-picture"
            "pin on, match:initial_title Picture-in-picture"

            "float on, match:initial_title Picture-in-Picture"
            "pin on, match:initial_title Picture-in-Picture"

            "float on, match:initial_title Picture in picture"
            "pin on, match:initial_title Picture in picture"

            # ========= ========= ========= ========= ========= =========
            # YouTube Music
            # ========= ========= ========= ========= ========= =========

            "workspace 1, match:initial_class YouTube.Music"

            # ========= ========= ========= ========= ========= =========
            # XDG Desktop Portal
            # ========= ========= ========= ========= ========= =========

            "float on, match:initial_class Xdg-desktop-portal-gtk"
            "pin on, match:initial_class Xdg-desktop-portal-gtk"
            "opacity 0.8, match:initial_class Xdg-desktop-portal-gtk"
            "center on, match:initial_class Xdg-desktop-portal-gtk"
            "size 934 489, match:initial_class Xdg-desktop-portal-gtk"

            # ========= ========= ========= ========= ========= =========
            # Steam
            # ========= ========= ========= ========= ========= =========

            # Friend List
            "float on, match:initial_class steam, match:initial_title Friends List"
            "center on, match:initial_class steam, match:initial_title Friends List"
            "size 524 706, match:initial_class steam, match:initial_title Friends List"

            "render_unfocused on, match:initial_class steam_app_2622380"

            # ========= ========= ========= ========= ========= =========
            # Obsidian
            # ========= ========= ========= ========= ========= =========
            "workspace 10, match:initial_class obsidian"
            # "no_initial_focus on, match:initial_class obsidian"

            # ========= ========= ========= ========= ========= =========
            # Zen
            # ========= ========= ========= ========= ========= =========
            "float on, match:initial_class zen-beta, match:title ^Extension:.*$"
            "center on, match:initial_class zen-beta, match:title ^Extension:.*$"
            "size 524 706, match:initial_class zen-beta, match:title ^Extension:.*$"

            # ========= ========= ========= ========= ========= =========
            # Mullvad VPN
            # ========= ========= ========= ========= ========= =========
            "float on, match:initial_title Mullvad VPN"
            "pin on, match:initial_title Mullvad VPN"

            # ========= ========= ========= ========= ========= =========
            # Sioyek
            # ========= ========= ========= ========= ========= =========
            "tile on, match:class sioyek"
          ];

          cursor = {
            # 2 is 'auto', which is recommended for NVIDIA
            no_hardware_cursors = 2;
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
            repeat_delay = 500;
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
            dim_modal = true;

            blur = {
              enabled = true;
              size = 3;
              passes = 1;
            };
          };

          animations = {
            enabled = "yes";
          };

          bezier = [
            "myBezier, 0.05, 0.9, 0.1, 1.05"
          ];

          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];

          dwindle = {
            pseudotile = "yes";
            preserve_split = "yes";
          };

          gestures = {
          };

          misc = {
            force_default_wallpaper = 0;
            mouse_move_enables_dpms = false;
            vrr = 2;
            enable_anr_dialog = false;
            disable_hyprland_guiutils_check = true;
          };

          render = {
            direct_scanout = 0;
          };
        };
    };

    # Add GTK portal for OpenURI, file chooser, etc.

    # Don't set xdg.portal.config - let configPackages from Hyprland handle it
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

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
        pkgs.unstable.hyprpicker

        pkgs.unstable.egl-wayland
        pkgs.unstable.wl-clipboard

        # pkgs.unstable.hyprcursor
        # pkgs.catppuccin-cursors.mochaMauve

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

        inputs.capTUre.packages.${system}.default
      ];
    };

    hardware.graphics = {
      enable = true;
      package = hypr-nixpkgs.mesa;

      enable32Bit = true;
      package32 = hypr-nixpkgs.pkgsi686Linux.mesa;

      extraPackages = [ ];
    };

    universe.hm = [
      {
        home.pointerCursor = {
          gtk.enable = true;
          package = pkgs.catppuccin-cursors.mochaLight;
          name = "Catppuccin-Mocha-Light-Cursors";
          size = 26;
        };

        # TODO: make this configurable
        # dimming
        # services.wlsunset = {
        #   enable = true;
        #
        #   latitude = 48.2081;
        #   longitude = 16.3713;
        #
        #   temperature = {
        #     day = 6500;
        #     night = 4500;
        #   };
        # };
      }
    ];
  };
}
