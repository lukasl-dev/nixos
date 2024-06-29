{
  programs.waybar.settings = {
    mainBar = {
      layer = "top";
      position = "top";

      modules-left = [ "temperature" "memory" "cpu" ];
      modules-center = [ "custom/music" ];
      modules-right = [ "wireplumber" "clock" "tray" ];

      tray = {
        icon-size = 21;
        spacing = 10;
      };

      "custom/music" = {
        format = "   {}";
        escape = true;
        interval = 1;
        tooltip = false;
        exec = "playerctl metadata --format='{{ title }}'";
        on-click = "playerctl play-pause";
        max-length = 50;
      };

      cpu = {
        format = "    {usage}%";
        interval = 1;
        on-click = "alacritty -e btop";
      };

      temperature = {
        format = "    {temperatureC} °C";
        interval = 1;
        on-click = "alacritty -e btop";
      };

      memory = {
        format = "    {}%";
        interval = 1;
        on-click = "alacritty -e btop";
      };  
      
      wireplumber = {
        format = " {icon}   {volume}%";
        format-muted = "  ";
        format-icons = {
          default = ["" "" " "];
        };
        on-click = "wpctl";
      };

      clock = {
        timezone = "Europe/Vienna";
        format = " {:%d/%m/%Y %H:%M}";
      };
    };
  };
}
