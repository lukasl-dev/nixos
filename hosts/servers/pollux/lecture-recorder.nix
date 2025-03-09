{ config, pkgs, ... }:

let
  ffmpeg = "${pkgs.ffmpeg}/bin/ffmpeg";
  script = channel: duration: ''
    day=$(date +'%d')
    month=$(date +'%m')
    year=$(date +'%Y')
    hour=$(date +'%H')
    minute=$(date +'%M')

    timestamp=$day-$month-$year-$hour-$minute
    mkv_file="/tmp/lecture_${channel}_$timestamp.mkv"

    printf "Recording %s to %s\n" "${duration}" "$mkv_file"
    ${ffmpeg} -headers "Referer: https://tuwel.tuwien.ac.at\r\n" \
      -t "${duration}" \
      -i "https://live-cdn-2.video.tuwien.ac.at/lecturetube-live/${channel}/playlist.m3u8" \
      -c:a copy "$mkv_file"
    printf "Finished recording at %s\n" "$(date)"

    echo "Moving to nextcloud"

    out_dir="${config.services.nextcloud.datadir}/data/root/files/Lectures/$year/$month/$day/${channel}"
    mkdir -p "$out_dir"

    out_file="$out_dir/$hour-$minute.mkv"
    mv "$mkv_file" "$out_file"

    /run/current-system/sw/bin/nextcloud-occ files:scan root --path "/root/files/Lectures/$year/$month/$day/${channel}/$hour-$minute.mkv"
  '';
  # TODO: don't use /run/current-system, ideally use nix syntax

  service = channel: duration: {
    description = "lecture-${channel}-${duration}";
    script = script channel duration;
    startLimitIntervalSec = 0;
    serviceConfig = {
      User = "nextcloud";
      Restart = "on-failure";
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

    informatik-1h = service "deu116-informatikhoersaal" "3600";
    informatik-2h = service "deu116-informatikhoersaal" "7200";
    informatik-3h = service "deu116-informatikhoersaal" "10800";

    tmp-recording = service "bau178a-gm-1-audi-max" "5";
  };

  systemd.timers = {
    mon-08-audimax = timer "audimax-2h.service" "Mon 08:00";
    mon-12-audimax = timer "audimax-2h.service" "Mon 12:00";
    mon-14-audimax = timer "audimax-2h.service" "Mon 14:00";

    tue-08-audimax = timer "audimax-2h.service" "Tue 08:00";
    tue-10-audimax = timer "audimax-2h.service" "Tue 10:00";
    tue-12-audimax = timer "audimax-2h.service" "Tue 12:00";
    tue-14-audimax = timer "audimax-2h.service" "Tue 14:00";

    wed-14-audimax = timer "audimax-2h.service" "Wed 14:00";

    thu-13-audimax = timer "audimax-2h.service" "Thu 13:00";

    fri-09-audimax = timer "audimax-2h.service" "Fri 09:00";
    fri-11-audimax = timer "audimax-2h.service" "Fri 11:00";
    fri-11-informatik = timer "informatik-3h.service" "Fri 11:00";
  };
}
