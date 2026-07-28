{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  cfg = planet.desktop.hyprland.keyboardDebounce;

  python = pkgs.python3.withPackages (packages: [ packages.evdev ]);

  keyboardDebounce = pkgs.writeTextFile {
    name = "keyboard-debounce";
    executable = true;
    destination = "/bin/keyboard-debounce";
    text = ''
      #!${python}/bin/python3

      import argparse
      import selectors
      import threading
      import time

      from evdev import InputDevice, UInput, ecodes, list_devices


      def parse_args():
          parser = argparse.ArgumentParser(
              description="Suppress rapid key chatter from evdev keyboards"
          )
          parser.add_argument("--device", action="append", default=[])
          parser.add_argument("--device-name", action="append", default=[])
          parser.add_argument("--threshold-ms", type=float, default=30)
          parser.add_argument("keys", nargs="+", metavar="KEY")
          args = parser.parse_args()
          if not args.device and not args.device_name:
              parser.error("at least one --device or --device-name is required")
          return args


      def find_device(kind, identifier):
          if kind == "path":
              return InputDevice(identifier)

          matches = []
          for path in list_devices():
              try:
                  device = InputDevice(path)
              except OSError:
                  continue
              if device.name == identifier:
                  matches.append(device)
              else:
                  device.close()

          if not matches:
              return None
          if len(matches) > 1:
              paths = ", ".join(device.path for device in matches)
              for device in matches:
                  device.close()
              raise RuntimeError(
                  f"multiple devices named {identifier!r}: {paths}"
              )
          return matches[0]


      def debounce_device(device, keys, key_names, threshold, threshold_ms):
          device.grab()
          output = UInput.from_device(
              device,
              name=f"{device.name} (debounced)",
              bustype=device.info.bustype,
              vendor=device.info.vendor,
              product=device.info.product,
              version=device.info.version,
          )
          selector = selectors.DefaultSelector()
          selector.register(device.fd, selectors.EVENT_READ)

          # Releases are delayed briefly. If the key is pressed again during
          # that interval, both events are chatter and are discarded. Delaying
          # release also prevents a chattering held key from being interrupted.
          pending_releases = {}

          def flush_releases(now):
              due = [
                  key
                  for key, deadline in pending_releases.items()
                  if deadline <= now
              ]
              for key in due:
                  output.write(ecodes.EV_KEY, key, 0)
                  del pending_releases[key]
              if due:
                  output.syn()

          print(
              f"debouncing {', '.join(key_names)} on {device.path} "
              f"({device.name}) with a {threshold_ms:g} ms threshold",
              flush=True,
          )

          try:
              while True:
                  now = time.monotonic()
                  flush_releases(now)

                  timeout = None
                  if pending_releases:
                      timeout = max(0, min(pending_releases.values()) - now)

                  if not selector.select(timeout):
                      continue

                  flush_releases(time.monotonic())

                  for event in device.read():
                      if event.type != ecodes.EV_KEY or event.code not in keys:
                          output.write_event(event)
                          continue

                      if event.value == 0:
                          pending_releases[event.code] = (
                              time.monotonic() + threshold
                          )
                      elif event.value == 1 and event.code in pending_releases:
                          elapsed = threshold - (
                              pending_releases[event.code] - time.monotonic()
                          )
                          print(
                              f"suppressed {ecodes.KEY[event.code]} chatter "
                              f"after {elapsed * 1000:.1f} ms on {device.path}",
                              flush=True,
                          )
                          del pending_releases[event.code]
                      else:
                          output.write_event(event)
          finally:
              selector.close()
              output.close()
              device.close()


      def device_worker(kind, identifier, args, keys, threshold):
          label = identifier if kind == "path" else repr(identifier)
          waiting = False

          while True:
              device = None
              try:
                  device = find_device(kind, identifier)
                  if device is None:
                      if not waiting:
                          print(f"waiting for keyboard {label}", flush=True)
                          waiting = True
                      time.sleep(2)
                      continue

                  waiting = False
                  debounce_device(
                      device,
                      keys,
                      args.keys,
                      threshold,
                      args.threshold_ms,
                  )
              except OSError as error:
                  if device is not None:
                      device.close()
                  print(f"keyboard {label} unavailable: {error}", flush=True)
                  time.sleep(2)
              except RuntimeError as error:
                  print(error, flush=True)
                  time.sleep(2)


      def main():
          args = parse_args()
          threshold = args.threshold_ms / 1000

          try:
              keys = {ecodes.ecodes[key] for key in args.keys}
          except KeyError as error:
              raise SystemExit(f"unknown evdev key: {error.args[0]}") from error

          devices = [*(('path', path) for path in args.device)]
          devices.extend(('name', name) for name in args.device_name)

          threads = [
              threading.Thread(
                  target=device_worker,
                  args=(kind, identifier, args, keys, threshold),
                  name=f"keyboard-debounce-{index}",
              )
              for index, (kind, identifier) in enumerate(devices)
          ]
          for thread in threads:
              thread.start()
          for thread in threads:
              thread.join()


      if __name__ == "__main__":
          main()
    '';
  };
in
{
  options.planet.desktop.hyprland.keyboardDebounce = {
    enable = lib.mkEnableOption "evdev keyboard chatter suppression";

    devices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "/dev/input/by-id/usb-example-event-kbd" ];
      description = "Stable evdev paths of keyboards to filter.";
    };

    deviceNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "Glove80 Keyboard" ];
      description = "Exact evdev device names to discover at service startup.";
    };

    keys = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.str;
      default = [ "KEY_O" ];
      description = "Linux evdev key names to debounce.";
    };

    thresholdMs = lib.mkOption {
      type = lib.types.ints.between 1 100;
      default = 30;
      description = "Release-to-press interval treated as switch chatter.";
    };
  };

  config = lib.mkIf (planet.desktop.enable && cfg.enable) {
    assertions = [
      {
        assertion = cfg.devices != [ ] || cfg.deviceNames != [ ];
        message = "keyboardDebounce requires at least one device or device name";
      }
    ];

    boot.kernelModules = [ "uinput" ];

    systemd.services.keyboard-debounce = {
      description = "Keyboard chatter suppression";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-udevd.service" ];

      serviceConfig = {
        ExecStart = lib.escapeShellArgs (
          [
            (lib.getExe keyboardDebounce)
            "--threshold-ms"
            (toString cfg.thresholdMs)
          ]
          ++ lib.concatMap (device: [
            "--device"
            device
          ]) cfg.devices
          ++ lib.concatMap (deviceName: [
            "--device-name"
            deviceName
          ]) cfg.deviceNames
          ++ cfg.keys
        );
        Restart = "always";
        RestartSec = "2s";
      };
    };
  };
}
