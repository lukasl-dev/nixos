{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelModules = [
      "nct6775"
      "coretemp"
      "hp-wmi"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = false;
      limine = {
        enable = true;
        # Install as a normal EFI boot entry (not fallback path)
        efiInstallAsRemovable = false;
      };
    };
    supportedFilesystems = {
      ntfs = true;
    };
  };

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "hp_wmi_boost_fan";
      runtimeInputs = [ pkgs.coreutils ];
      text = # bash
        ''
          set -e 

          TARGET_FILE="/sys/devices/platform/hp-wmi/hwmon/hwmon1/pwm1_enable"

          if [ ! -f "$TARGET_FILE" ]; then
              echo "ERROR: Target file not found: $TARGET_FILE" >&2
              echo "Please ensure the path is correct and the hp-wmi kernel module is loaded." >&2
              exit 1
          fi

          current_value=$(tr -d '[:space:]' < "$TARGET_FILE")

          echo "Current fan setting in $TARGET_FILE is: '$current_value'"

          new_value=""
          if [ "$current_value" = "0" ]; then
              new_value="2"
          else
              new_value="0"
          fi

          echo "Changing fan setting to: '$new_value'"

          if echo "$new_value" > "$TARGET_FILE"; then
              echo "Successfully changed fan setting to '$new_value'."
          else
              echo "ERROR: Failed to write '$new_value' to $TARGET_FILE." >&2
              echo "Please make sure you are running this script with sudo privileges." >&2
              exit 1 
          fi

          exit 0

        '';
    })
  ];

  services = {
    thermald.enable = true;
    tlp = {
      enable = true;
      settings = {
        TLP_DEFAULT_MODE = "BAT";
        TLP_PERSISTENT_DEFAULT = 1;
        SOUND_POWER_SAVE_ON_AC = 0;
        SOUND_POWER_SAVE_ON_BAT = 0;
        USB_EXCLUDE_BTUSB = 1;
      };
    };
  };

  planet = {
    name = "orion";
    timeZone = "Europe/Vienna";

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
          "eDP-1, 1920x1080@144.02800, 0x0, 1"
        ];
      };
    };

    audio.enable = true;

    programs = {
      anki.enable = true;
    };

    services = {
      mullvad.enable = true;
    };
  };

}
