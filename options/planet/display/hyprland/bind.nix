let
  lua =
    mod:
    # lua
    ''
      hl.bind("${mod} + W", hl.dsp.window.close())
      hl.bind("${mod} + SHIFT + W", hl.dsp.window.kill())

      hl.bind("${mod} + mouse:272", hl.dsp.window.drag(), { mouse = true })
      hl.bind("${mod} + mouse:273", hl.dsp.window.resize(), { mouse = true })

      hl.bind("${mod} + H", hl.dsp.focus({ direction = "l" }))
      hl.bind("${mod} + J", hl.dsp.focus({ direction = "d" }))
      hl.bind("${mod} + K", hl.dsp.focus({ direction = "u" }))
      hl.bind("${mod} + L", hl.dsp.focus({ direction = "r" }))

      hl.bind("${mod} + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
      hl.bind("${mod} + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
      hl.bind("${mod} + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
      hl.bind("${mod} + SHIFT + L", hl.dsp.window.move({ direction = "r" }))

      hl.bind("${mod} + CONTROL + H", hl.dsp.window.swap({ direction = "l" }))
      hl.bind("${mod} + CONTROL + J", hl.dsp.window.swap({ direction = "d" }))
      hl.bind("${mod} + CONTROL + K", hl.dsp.window.swap({ direction = "u" }))
      hl.bind("${mod} + CONTROL + L", hl.dsp.window.swap({ direction = "r" }))

      hl.bind("${mod} + 1", hl.dsp.focus({ workspace = "1" }))
      hl.bind("${mod} + 2", hl.dsp.focus({ workspace = "2" }))
      hl.bind("${mod} + 3", hl.dsp.focus({ workspace = "3" }))
      hl.bind("${mod} + 4", hl.dsp.focus({ workspace = "4" }))
      hl.bind("${mod} + 5", hl.dsp.focus({ workspace = "5" }))
      hl.bind("${mod} + 6", hl.dsp.focus({ workspace = "6" }))
      hl.bind("${mod} + 7", hl.dsp.focus({ workspace = "7" }))
      hl.bind("${mod} + 8", hl.dsp.focus({ workspace = "8" }))
      hl.bind("${mod} + 9", hl.dsp.focus({ workspace = "9" }))
      hl.bind("${mod} + 0", hl.dsp.focus({ workspace = "0" }))

      hl.bind("${mod} + SHIFT + 1", hl.dsp.window.move({ workspace = "1" }))
      hl.bind("${mod} + SHIFT + 2", hl.dsp.window.move({ workspace = "2" }))
      hl.bind("${mod} + SHIFT + 3", hl.dsp.window.move({ workspace = "3" }))
      hl.bind("${mod} + SHIFT + 4", hl.dsp.window.move({ workspace = "4" }))
      hl.bind("${mod} + SHIFT + 5", hl.dsp.window.move({ workspace = "5" }))
      hl.bind("${mod} + SHIFT + 6", hl.dsp.window.move({ workspace = "6" }))
      hl.bind("${mod} + SHIFT + 7", hl.dsp.window.move({ workspace = "7" }))
      hl.bind("${mod} + SHIFT + 8", hl.dsp.window.move({ workspace = "8" }))
      hl.bind("${mod} + SHIFT + 9", hl.dsp.window.move({ workspace = "9" }))
      hl.bind("${mod} + SHIFT + 0", hl.dsp.window.move({ workspace = "0" }))

      hl.bind("${mod} + M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
      hl.bind("${mod} + SHIFT + M", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

      hl.bind("${mod} + MINUS", hl.dsp.layout("colresize -conf"))
      hl.bind("${mod} + EQUAL", hl.dsp.layout("colresize +conf"))

      hl.bind("${mod} + E", function() 
        hl.dispatch(hl.dsp.window.float())
        hl.dispatch(hl.dsp.window.center())
      end)
    '';
in
{
  planet.display.hyprland.lua = [
    (lua "SUPER")
    (lua "ALT")
  ];
}
