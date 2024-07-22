{
  wayland.windowManager.hyprland.settings = {
    windowrule = [];

    windowrulev2 = [
      "float,title:(Picture-in-picture)"
      "float,class:(Rofi)"
      "float,class:(1Password)"
      "float,title:(Save File)"
      "float,title:(Open File)"
      "float,initialTitle:(discord popout)"

      # "opacity 0.0 override,class:^(xwaylandvideobridge)$"
      # "noanim,class:^(xwaylandvideobridge)$"
      # "noinitialfocus,class:^(xwaylandvideobridge)$"
      # "maxsize 1 1,class:^(xwaylandvideobridge)$"
      # "noblur,class:^(xwaylandvideobridge)$"

      "workspace 1,initialClass:(vesktop)"
      
      "workspace 1,initialTitle:(YouTube Music)"

      "pin,title:(.*)is sharing your screen(.*)"
      "move 100%-w-35% 0%,title:(.*)is sharing your screen(.*)"
      "bordersize 0,title:(.*)is sharing your screen(.*)"
      # "maxsize 500 968,initialTitle:(YouTube Music)"
    ];
  };
}
