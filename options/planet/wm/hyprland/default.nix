{
  inputs,
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:

let
  inherit (config.planet.wm) hyprland;

  inherit (pkgs.stdenv.hostPlatform) system;
  hypr-pkgs = inputs.hyprland.packages.${system};
in
{
  imports = [
    ./cursors.nix
    ./graphics.nix
  ];

  options = {
    planet.wm.hyprland = {
      enable = lib.mkEnableOption "Enable Hyprland";

      mod = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = "SUPER";
        description = "Main modifier used for Hyprland bindings.";
      };

      monitors = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "eDP-1" ];
        description = "List of monitors to use with Hyprland. Use the output of 'hyprctl monitors' to get the correct names.";
      };
    };
  };

  config = lib.mkIf hyprland.enable {
    nix.settings = {
      substituters = lib.mkAfter [
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = lib.mkAfter [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    environment.systemPackages = with pkgs-unstable; [
      egl-wayland
      wl-clipboard
    ];

    programs.hyprland =
      let
        hypr-pkgs = inputs.hyprland.packages.${system};
        inherit (hypr-pkgs) hyprland xdg-desktop-portal-hyprland;
      in
      {
        enable = true;

        package = hyprland;
        portalPackage = xdg-desktop-portal-hyprland;

        xwayland.enable = true;
        withUWSM = false;
      };

    universe.hm = [
      {
        imports = [ inputs.hyprland.homeManagerModules.default ];

        wayland.windowManager.hyprland = {
          enable = true;
          package = hypr-pkgs.hyprland;

          sourceFirst = true;
          xwayland.enable = true;
          systemd = {
            enable = true;
            variables = [ "--all" ];
          };

          settings = {
            monitor = hyprland.monitors ++ [ "Unknown-1,disable" ];

            general = {
              gaps_in = 5;
              gaps_out = 30;
              border_size = 2;

              "col.active_border" = "$mauve $lavender 45deg";
              "col.inactive_border" = "rgba(595959aa)";

              layout = "dwindle";

              allow_tearing = false;
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

            misc = {
              force_default_wallpaper = 0;
              mouse_move_enables_dpms = false;
              vrr = 1;
              enable_anr_dialog = false;
            };

            gestures.workspace_swipe = "off";
            cursor.no_hardware_cursors = true;
            render.direct_scanout = 1;
          };
        };
      }
    ];
  };
}
