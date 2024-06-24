const date = Variable("", {
	poll: [1000, 'date "+%a, %d. %b %H:%M"'],
});

function Clock() {
	return Widget.Label({
		class_name: "clock",
		label: date.bind(),
	});
}

function Center() {
	return Widget.Box({
		spacing: 8,
		children: [Clock()],
	});
}

function Bar(monitor = 0) {
	return Widget.Window({
		name: `bar-${monitor}`,
		class_name: "bar",
		monitor,
		anchor: ["top", "left", "right"],
		exclusivity: "exclusive",
		child: Widget.CenterBox({
			center_widget: Center(),
		}),
	});
}

App.config({
	style: "./style.css",
	windows: [Bar(0), Bar(1)],
});

export {};
