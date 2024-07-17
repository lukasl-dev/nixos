{
  wayland.windowManager.hyprland.sourceFirst = true;
  wayland.windowManager.hyprland.settings = {
    env = [
      "XCURSOR_SIZE,24"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      "QT_QPA_PLATFORM,wayland"
      "NVD_BACKEND,direct"
    ];

    monitor = [
      "DP-3,1920x1080@240,0x0,1"
      "HDMI-A-1,1920x1080@75,1920x0,1"
      "Unknown-1,disable"
    ];

    exec-once = [
      "waybar"
      "1password"
      "vesktop"
      "wl-paste --type text --watch cliphist store"
    ];

    input = {
      kb_layout = "us";
      kb_variant = ",qwerty";
      follow_mouse = 1;
      touchpad = {
        natural_scroll = "no";
      };
      sensitivity = 0;
      # repeat_rate = 25;
      # repeat_delay = 0;
    };

    general = {
      gaps_in = 5;
      gaps_out = 30;
      border_size = 2;

      "col.active_border" = "$mauve $lavender 45deg";
      "col.inactive_border" = "rgba(595959aa)";

      layout = "dwindle";

      allow_tearing = true;
    };

    decoration = {
      rounding = 10;

      blur = {
        enabled = true;
        size = 3;
        passes = 1;
      };

      "drop_shadow" = "yes";
      shadow_range = 4;
      shadow_render_power = 3;
      "col.shadow" = "$crust";
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
    };
  };
}
