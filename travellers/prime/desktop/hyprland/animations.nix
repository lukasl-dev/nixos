{
  config.traveller.desktop.hyprland.lua = # lua
    ''
      hl.curve("myBezier", {
        type = "bezier",
        points = {
          { 0.05, 0.9 },
          { 0.1, 1.05 },
        },
      })

      hl.animation({
        leaf = "windows",
        speed = 7,
        bezier = "myBezier",
      })
      hl.animation({
        leaf = "windowsOut",
        speed = 7,
        bezier = "default",
        style = "popin 80%",
      })
      hl.animation({
        leaf = "border",
        speed = 10,
        bezier = "default",
      })
      hl.animation({
        leaf = "borderangle",
        speed = 8,
        bezier = "default",
      })
      hl.animation({
        leaf = "fade",
        speed = 7,
        bezier = "default",
      })
      hl.animation({
        leaf = "workspaces",
        speed = 6,
        bezier = "default",
      })
    '';
}
