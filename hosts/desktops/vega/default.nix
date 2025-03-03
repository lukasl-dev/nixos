{ pkgs, ... }:

{
  imports = [
    ../default.nix
    ./hardware-configuration.nix

    ../../../modules/ollama.nix
  ];

  networking.hostName = "vega";

  boot = {
    kernelModules = [
      "nct6775"
      "coretemp"
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = {
      ntfs = true;
    };
  };

  # TODO: this is highly likely redundant

  environment.sessionVariables = {
    WWLR_NO_HARDWARE_CURSORSLR_NO_HARDWARE_CURSORS = "1";

    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";

    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.coolercontrol = {
    enable = true;
    nvidiaSupport = true;
  };

  environment.systemPackages = [
    pkgs.ffmpeg
  ];

  systemd =
    let
      script = channel: duration: ''
        dir="/home/lukas/tutils/recordings/$(date +'%Y/%m/%d')/${channel}"
        mkdir -p "$dir"

        out_file="$dir/$(date +'%H-%M').ts"

        printf "Recording ${duration} to %s\n" "$out_file"
        printf "Started at %s\n" "$(date)"

        ${pkgs.ffmpeg}/bin/ffmpeg -headers "Referer: https://tuwel.tuwien.ac.at\r\n" \
               -t "${duration}" \
               -i "https://live-cdn-2.video.tuwien.ac.at/lecturetube-live/${channel}/playlist.m3u8" \
               -c copy "$out_file"

        printf "Finished at %s\n" "$(date)"
      '';

      service = channel: duration: {
        description = "lecture-${channel}-${duration}";
        script = script channel duration;
        serviceConfig = {
          Type = "oneshot";
          User = "lukas";
        };
      };

      timer = unit: calendar: {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = calendar;
          Unit = unit;
        };
      };
    in
    {
      services = {
        "audimax-7200" = service "bau178a-gm-1-audi-max" "7200";
      };

      timers = {
        "monday-08am" = timer "audimax-7200.service" "Mon 08:00";
        "monday-12am" = timer "audimax-7200.service" "Mon 12:00";
        "monday-14am" = timer "audimax-7200.service" "Mon 14:00";
      };
    };
}
