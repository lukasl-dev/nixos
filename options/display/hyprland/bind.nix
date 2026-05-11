{
  planet.display.hyprland.lua = [
    # lua
    ''
      hl.bind("SUPER + W", hl.dsp.window.close())
      hl.bind("SUPER + SHIFT + W", hl.dsp.window.kill())

      hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }))
      hl.bind("ALT + H", hl.dsp.focus({ direction = "l" }))
      hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }))
      hl.bind("ALT + J", hl.dsp.focus({ direction = "d" }))
      hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }))
      hl.bind("ALT + K", hl.dsp.focus({ direction = "u" }))
      hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }))
      hl.bind("ALT + L", hl.dsp.focus({ direction = "r" }))

      hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
      hl.bind("ALT + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
      hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
      hl.bind("ALT + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
      hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
      hl.bind("ALT + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
      hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
      hl.bind("ALT + SHIFT + L", hl.dsp.window.move({ direction = "r" }))

      hl.bind("SUPER + CONTROL + H", hl.dsp.window.swap({ direction = "l" }))
      hl.bind("ALT + CONTROL + H", hl.dsp.window.swap({ direction = "l" }))
      hl.bind("SUPER + CONTROL + J", hl.dsp.window.swap({ direction = "d" }))
      hl.bind("ALT + CONTROL + J", hl.dsp.window.swap({ direction = "d" }))
      hl.bind("SUPER + CONTROL + K", hl.dsp.window.swap({ direction = "u" }))
      hl.bind("ALT + CONTROL + K", hl.dsp.window.swap({ direction = "u" }))
      hl.bind("SUPER + CONTROL + L", hl.dsp.window.swap({ direction = "r" }))
      hl.bind("ALT + CONTROL + L", hl.dsp.window.swap({ direction = "r" }))

      hl.bind("SUPER + 1", hl.dsp.focus({ workspace = "1" }))
      hl.bind("SUPER + 2", hl.dsp.focus({ workspace = "2" }))
      hl.bind("SUPER + 3", hl.dsp.focus({ workspace = "3" }))
      hl.bind("SUPER + 4", hl.dsp.focus({ workspace = "4" }))
      hl.bind("SUPER + 5", hl.dsp.focus({ workspace = "5" }))
      hl.bind("SUPER + 6", hl.dsp.focus({ workspace = "6" }))
      hl.bind("SUPER + 7", hl.dsp.focus({ workspace = "7" }))
      hl.bind("SUPER + 8", hl.dsp.focus({ workspace = "8" }))
      hl.bind("SUPER + 9", hl.dsp.focus({ workspace = "9" }))
      hl.bind("SUPER + 0", hl.dsp.focus({ workspace = "0" }))

      hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = "1" }))
      hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = "2" }))
      hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = "3" }))
      hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = "4" }))
      hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = "5" }))
      hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = "6" }))
      hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = "7" }))
      hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = "8" }))
      hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = "9" }))
      hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = "0" }))

      hl.bind("SUPER + M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
      hl.bind("SUPER + SHIFT + M", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

      hl.bind("SUPER + MINUS", hl.dsp.layout("colresize -conf"))
      hl.bind("SUPER + EQUAL", hl.dsp.layout("colresize +conf"))

      hl.bind("SUPER + V", function() 
        hl.dispatch(hl.dsp.window.float())
        hl.dispatch(hl.dsp.window.center())
      end)
    ''
  ];
}
#   type = "dispatch";
#   mods = windowMods;
#   keys = [ "minus" ];
#   dispatcher = "layoutmsg";
#   argument = "colresize -conf";
# }
# {
#   type = "dispatch";
#   mods = windowMods;
#   keys = [ "equal" ];
#   dispatcher = "layoutmsg";
#   argument = "colresize +conf";
# }
