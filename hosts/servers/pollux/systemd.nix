{ meta, pkgs, ... }:

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
    startLimitIntervalSec = 0;
    serviceConfig = {
      User = meta.user.name;
      Restart = "always";
      RestartSec = 2;
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
  systemd.services = {
    audimax-1h = service "bau178a-gm-1-audi-max" "3600";
    audimax-2h = service "bau178a-gm-1-audi-max" "7200";
  };

  systemd.timers = {
    mon-08 = timer "audimax-2h.service" "Mon 08:00";
    mon-12 = timer "audimax-2h.service" "Mon 12:00";
    mon-14 = timer "audimax-2h.service" "Mon 14:00";

    tue-08 = timer "audimax-2h.service" "Tue 08:00";
    tue-10 = timer "audimax-2h.service" "Tue 10:00";
    tue-12 = timer "audimax-2h.service" "Tue 12:00";
    tue-14 = timer "audimax-2h.service" "Tue 14:00";

    wed-14 = timer "audimax-2h.service" "Wed 14:00";

    thu-13 = timer "audimax-2h.service" "Thu 13:00";

    fri-09 = timer "audimax-2h.service" "Fri 09:00";
    fri-11 = timer "audimax-2h.service" "Fri 11:00";
  };
}
