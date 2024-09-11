{
  programs.waybar.settings = {
    mainBar = {
      layer = "top";
      position = "top";

      modules-left = [ "temperature" "memory" "cpu" "custom/nvidia" ];
      modules-center = [ "hyprland/workspaces" ];
      modules-right = [ "custom/mic" "wireplumber" "clock" "tray" ];

      tray = {
        icon-size = 21;
        spacing = 10;
      };

      cpu = {
        format = "   {usage}%";
        interval = 1;
        on-click = "alacritty -e btop";
      };

      "custom/nvidia" = {
        format = "  {}%";
        escape = true;
        interval = 1;
        tooltip = false;
        exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits";
        on-click = "alacritty -e btop";
        max-length = 50;
      };

      temperature = {
        format = "  {temperatureC} °C";
        interval = 1;
        on-click = "alacritty -e btop";
      };

      memory = {
        format = "   {}%";
        interval = 1;
        on-click = "alacritty -e btop";
      };  

      "hyprland/workspaces" = {
        format = "{icon}";
        on-click = "activate";
        sort-by-number = true;
      };

      "custom/mic" = {
        format = "{}";
        escape = true;
        interval = 1;
        tooltip = false;
        exec = ''
          wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print ($NF == "[MUTED]") ? " " : "  " int($2*100)"%"}'
        '';
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        max-length = 50;
      };
      
      wireplumber = {
        format = "{icon}   {volume}%";
        format-muted = " ";
        format-icons = {
          default = ["" "" " "];
        };
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

      clock = {
        timezone = "Europe/Vienna";
        format = " {:%d/%m/%Y %H:%M}";
      };
    };
  };
}
