{ pkgs, ... }:

{
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 20;
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };

  environment.systemPackages = with pkgs; [ gamemode ];
}
