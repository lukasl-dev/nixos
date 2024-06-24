const date = Variable("", {
  poll: [1000, 'date "+%a, %d. %b %H:%M"'],
})

function Clock() {
  return Widget.Label({
    class_name: "clock",
    label: date.bind(),
  })
}

function Center() {
  return Widget.Box({
    spacing: 8,
    children: [Clock()],
  })
}

function Bar(monitor: number) {
  return Widget.Window({
    monitor,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
      center_widget: Center(),
    }),
    css: `
      background-color: #1e1e2e;
      color: white;
      font-family: "JetBrainsMono", sans-serif;
      font-weight: bold;
    `,
  })
}

App.config({
  windows: [Bar(0), Bar(1)],
})

export {}
