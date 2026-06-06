{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet) display;
  inherit (config.planet.display) hyprland;
  inherit (config.planet.programs) gpu-screen-recorder;

  cfg = gpu-screen-recorder;

  notify = ''${lib.getExe' pkgs.libnotify "notify-send"} --app-name gpu-screen-recorder --icon video-x-generic'';

  control = pkgs.writeShellScriptBin "gpu-screen-recorder-control" ''
    set -euo pipefail

    runtime_dir="''${XDG_RUNTIME_DIR:-/tmp}"
    recording_state="$runtime_dir/gpu-screen-recorder-recording.state"
    paused_state="$runtime_dir/gpu-screen-recorder-paused.state"

    signal_gsr() {
      pkill -"$1" -f '(^|/)gpu-screen-recorder( |$)'
    }

    case "''${1-}" in
      save-replay)
        if ! signal_gsr SIGUSR1; then
          ${notify} "GPU Screen Recorder is not running" || true
          exit 1
        fi
        ${notify} "Replay saved" "Saved the last ${toString cfg.replayBufferSize}s to ${cfg.replayDir}" || true
        ;;

      toggle-record)
        if ! signal_gsr SIGRTMIN; then
          ${notify} "GPU Screen Recorder is not running" || true
          exit 1
        fi
        if [ -f "$recording_state" ]; then
          rm -f "$recording_state"
          ${notify} "Recording stopped" "Saved to ${cfg.recordDir}" || true
        else
          touch "$recording_state"
          ${notify} "Recording started" "Recording ${cfg.captureTarget}" || true
        fi
        ;;

      toggle-pause)
        if ! signal_gsr SIGUSR2; then
          ${notify} "GPU Screen Recorder is not running" || true
          exit 1
        fi
        if [ -f "$paused_state" ]; then
          rm -f "$paused_state"
          ${notify} "Recording resumed" || true
        else
          touch "$paused_state"
          ${notify} "Recording paused" || true
        fi
        ;;

      *)
        echo "usage: $0 {save-replay|toggle-record|toggle-pause}" >&2
        exit 2
        ;;
    esac
  '';

  replayRecorder = pkgs.writeShellScriptBin "gpu-screen-recorder-replay" ''
    set -euo pipefail

    mkdir -p "${cfg.replayDir}" "${cfg.recordDir}"
    ${notify} "Replay buffer started" "Recording ${cfg.captureTarget}; save replay with SUPER+ALT+R" || true

    args=(-w "${cfg.captureTarget}")
    ${lib.optionalString (cfg.captureTarget == "portal") ''args+=(-restore-portal-session yes)''}

    exec ${lib.getExe pkgs.gpu-screen-recorder} \
      "''${args[@]}" \
      -f ${toString cfg.fps} \
      -q ${cfg.quality} \
      -a "${cfg.audioDevice}" \
      -c mkv \
      -r ${toString cfg.replayBufferSize} \
      -o "${cfg.replayDir}" \
      -ro "${cfg.recordDir}"
  '';

in
{
  options.planet.programs.gpu-screen-recorder = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = display.enable;
      description = "Enable gpu-screen-recorder";
    };

    replayDir = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/Videos/Replays";
      description = "Directory for replay videos.";
    };

    recordDir = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/Videos/Recordings";
      description = "Directory for regular recordings.";
    };

    replayBufferSize = lib.mkOption {
      type = lib.types.int;
      default = 60;
      description = "Replay buffer size in seconds.";
    };

    fps = lib.mkOption {
      type = lib.types.int;
      default = 60;
      description = "Frame rate for recording.";
    };

    quality = lib.mkOption {
      type = lib.types.enum [
        "medium"
        "high"
        "very_high"
        "ultra"
      ];
      default = "very_high";
      description = "Recording quality preset.";
    };

    audioDevice = lib.mkOption {
      type = lib.types.str;
      default = "default_output";
      description = "Audio input device for recording.";
    };

    captureTarget = lib.mkOption {
      type = lib.types.str;
      default = "DP-1";
      description = ''
        Capture target passed to gpu-screen-recorder's -w option. Use a monitor
        name from `gpu-screen-recorder --list-capture-options`, or values like
        "screen", "portal", "focused", or "region".
      '';
    };

    autoStartReplay = lib.mkOption {
      type = lib.types.bool;
      default = hyprland.enable;
      description = "Start replay buffer automatically with Hyprland.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.gpu-screen-recorder
      pkgs.libnotify
      control
      replayRecorder
    ];

    planet.display.hyprland.lua = lib.mkIf hyprland.enable (
      [
        # lua
        ''
          -- gpu-screen-recorder: save replay (SIGUSR1)
          hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd("${lib.getExe control} save-replay"))

          -- gpu-screen-recorder: start/stop regular recording in replay mode (SIGRTMIN)
          hl.bind("SUPER + R", hl.dsp.exec_cmd("${lib.getExe control} toggle-record"))

          -- gpu-screen-recorder: pause/unpause recording (SIGUSR2)
          hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("${lib.getExe control} toggle-pause"))
        ''
      ]
    );

    planet.display.hyprland.autoStart = lib.mkIf (hyprland.enable && cfg.autoStartReplay) [
      (lib.getExe replayRecorder)
    ];
  };
}
