{
  config.traveller.desktop.hyprland.lua = # lua
    ''
      local directions = {
        { key = "H", direction = "l" },
        { key = "J", direction = "d" },
        { key = "K", direction = "u" },
        { key = "L", direction = "r" },
      }

      for _, mod in ipairs({ "SUPER", "ALT" }) do
        hl.bind(mod .. " + W", hl.dsp.window.close())
        hl.bind(mod .. " + SHIFT + W", hl.dsp.window.kill())

        hl.bind(
          mod .. " + mouse:272",
          hl.dsp.window.drag(),
          { mouse = true }
        )
        hl.bind(
          mod .. " + mouse:273",
          hl.dsp.window.resize(),
          { mouse = true }
        )

        for _, binding in ipairs(directions) do
          local key = binding.key
          local direction = binding.direction

          hl.bind(
            mod .. " + " .. key,
            hl.dsp.focus({ direction = direction })
          )
          hl.bind(
            mod .. " + SHIFT + " .. key,
            hl.dsp.window.move({ direction = direction })
          )
          hl.bind(
            mod .. " + CONTROL + " .. key,
            hl.dsp.window.swap({ direction = direction })
          )
        end

        for workspace = 0, 9 do
          local key = tostring(workspace)

          hl.bind(
            mod .. " + " .. key,
            hl.dsp.focus({ workspace = key })
          )
          hl.bind(
            mod .. " + SHIFT + " .. key,
            hl.dsp.window.move({ workspace = key })
          )
        end

        hl.bind(
          mod .. " + M",
          hl.dsp.window.fullscreen({
            mode = "maximized",
            action = "toggle",
          })
        )
        hl.bind(
          mod .. " + SHIFT + M",
          hl.dsp.window.fullscreen({
            mode = "fullscreen",
            action = "toggle",
          })
        )

        hl.bind(mod .. " + MINUS", hl.dsp.layout("colresize -conf"))
        hl.bind(mod .. " + EQUAL", hl.dsp.layout("colresize +conf"))

        hl.bind(mod .. " + E", function()
          hl.dispatch(hl.dsp.window.float())
          hl.dispatch(hl.dsp.window.center())
        end)
      end
    '';
}
