const audio = await Service.import("audio")

const date = Variable("", {
  poll: [1000, 'date "+%H:%M:%S %b %e."'],
})

function Clock() {
  return Widget.Label({
    class_name: "clock",
    label: date.bind(),
  })
}


function Volume() {
  const icons = {
    101: "overamplified",
    67: "high",
    34: "medium",
    1: "low",
    0: "muted",
  }

  function getIcon() {
    const icon = audio.speaker.is_muted ? 0 : [101, 67, 34, 1, 0].find(
      threshold => threshold <= audio.speaker.volume * 100)

    return `audio-volume-${icons[icon]}-symbolic`
  }

  const icon = Widget.Icon({
    icon: Utils.watch(getIcon(), audio.speaker, getIcon),
  })

  const slider = Widget.Slider({
    hexpand: true,
    draw_value: false,
    on_change: ({ value }) => audio.speaker.volume = value,
    setup: self => self.hook(audio.speaker, () => {
      self.value = audio.speaker.volume || 0
    }),
  })

  return Widget.Box({
    class_name: "volume",
    css: "min-width: 180px",
    children: [icon, slider],
  })
}

function Right() {
  return Widget.Box({
    hpack: "end",
    spacing: 8,
    children: [
      Volume(),
      Clock(),
    ],
  })
}

function Bar(monitor = 0) {
  return Widget.Window({
    name: `bar-${monitor}`, // name has to be unique
    class_name: "bar",
    // monitor,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
      end_widget: Right(),
    }),
  })
}

App.config({
  style: "./style.css",
  windows: [
    Bar(),
  ],
})

export { }
