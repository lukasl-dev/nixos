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

      "opacity 0.0 override,class:^(xwaylandvideobridge)$"
      "noanim,class:^(xwaylandvideobridge)$"
      "noinitialfocus,class:^(xwaylandvideobridge)$"
      "maxsize 1 1,class:^(xwaylandvideobridge)$"
      "noblur,class:^(xwaylandvideobridge)$"

      "move 50% 100%,title:(is sharing your screen.)$"
    ];
  };
}
