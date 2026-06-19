{
  config,
  lib,
  ...
}:

let
  inherit (config.planet.display) hyprland;
in
{
  options.planet.display.hyprland = {
    config = lib.mkOption {
      type =
        with lib.types;
        let
          valueType = nullOr (oneOf [
            bool
            int
            float
            str
            path
            (attrsOf valueType)
            (listOf valueType)
          ]);
        in
        attrsOf valueType;
      default = {
        cursor = {
          # 2 is 'auto', which is recommended for NVIDIA
          no_hardware_cursors = 2;
        };

        input = {
          kb_layout = "us";
          kb_variant = ",qwerty";
          follow_mouse = 1;
          touchpad = {
            natural_scroll = true;
          };
          sensitivity = 0;

          # Only affects deliberate key holds, not switch chatter like a single
          # press producing two separate "o" events.
          repeat_rate = 25;
          repeat_delay = 200;
        };

        general = {
          gaps_in = 5;
          gaps_out = 30;
          border_size = 2;

          col = {
            active_border = {
              colors = [
                "rgb(cba6f7)"
                "rgb(b4befe)"
              ];
              angle = 45;
            };
            inactive_border = "rgba(595959aa)";
          };

          layout = "scrolling";

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
          enabled = true;
        };

        scrolling = {
          fullscreen_on_one_column = true;
          column_width = 0.5;
          focus_fit_method = 1;
          follow_focus = true;
          follow_min_visible = 0.4;
          explicit_column_widths = "0.333, 0.5, 0.667, 1.0";
          direction = "right";
        };

        gestures = { };

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
      example = {
        general = {
          gaps_in = 5;
          gaps_out = 10;
        };
      };
      description = "Hyprland config object to pass to hl.config.";
    };
  };

  config = lib.mkIf hyprland.enable {
    planet.display.hyprland.lua = lib.optional (hyprland.config != { }) ''
      hl.config(${lib.generators.toLua { } hyprland.config})
    '';
  };
}
