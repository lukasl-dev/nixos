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
        interval = 5;
        tooltip = false;
        exec = "playerctl metadata --format='{{ title }}'";
        on-click = "playerctl play-pause";
        max-length = 50;
      };

      cpu = {
        format = "    {}%";
        interval = 1;
      };

      temperature = {
        format = "    {temperatureC} °C";
        interval = 1;
      };

      memory = {
        format = "    {}%";
        interval = 1;
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
