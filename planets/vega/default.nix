{
  imports = [ ./hardware-configuration.nix ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1235", ATTR{idProduct}=="8219", TEST=="power/control", ATTR{power/control}="on"
  '';

  systemd.services.focusrite-usb-reinit = {
    description = "Reinitialize Focusrite Scarlett 2i2 on boot";
    wantedBy = [ "multi-user.target" ];
    wants = [ "systemd-udev-settle.service" ];
    after = [ "systemd-udev-settle.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -eu

      for device in /sys/bus/usb/devices/*; do
        [ -f "$device/idVendor" ] || continue
        [ -f "$device/idProduct" ] || continue
        [ -w "$device/authorized" ] || continue

        if [ "$(cat "$device/idVendor")" = "1235" ] && [ "$(cat "$device/idProduct")" = "8219" ]; then
          echo "Resetting Focusrite device at $device"
          echo 0 > "$device/authorized"
          sleep 1
          echo 1 > "$device/authorized"
        fi
      done
    '';
  };

  boot = {
    kernelModules = [
      "nct6775"
      "coretemp"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        efiInstallAsRemovable = true;
      };
    };
    supportedFilesystems = {
      ntfs = true;
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.settings.extra-platforms = [ "aarch64-linux" ];

  # # TODO: requires avahi
  # services.printing.enable = true;

  planet = {
    name = "vega";
    timeZone = "Europe/Vienna";
    stateVersion = "25.05";

    hardware = {
      bluetooth.enable = true;

      nvidia = {
        enable = true;
        cuda = true;
      };
    };

    wm = {
      enable = true;

      hyprland = {
        enable = true;
        monitors = [
          "DP-2, 1920x1080@239.96, 0x0, 1"
          "HDMI-A-1, 1920x1080@74.973, 1920x0, 1"
        ];
      };
    };

    audio.enable = true;

    programs = {
      anki.enable = true;
      uxplay.enable = true;
    };

    services = {
      mullvad.enable = true;
      flatpak.enable = true;
    };

    gaming = {
      enable = true;

      lutris.enable = true;
      bottles.enable = true;

      steam.enable = true;
      minecraft.enable = true;
      r2modman.enable = true;
    };

    development = {
      lean.enable = true;
      python.enable = true;
      R.enable = true;
    };

    networking.vpn.tu.enable = true;

    virtualisation = {
      libvirt = {
        enable = true;
        virt-manager.enable = true;
        winapps.enable = true;
        # domains = {
        #   RDPWindows = {
        #     source = ../../vms/RDPWindows.xml;
        #     autostart = false; # set to true if you want libvirt to autostart it
        #   };
        # };
      };
    };
  };
}
