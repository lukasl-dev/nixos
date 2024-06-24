{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = ./../../dots/rofi/themes/catppuccin-mocha.rasi;
# extraConfig = ''
#   configuration{
#       modi: "run,drun,window";
#       icon-theme: "Oranchelo";
#       show-icons: true;
#       terminal: "alacritty";
#       drun-display-format: "{icon} {name}";
#       location: 0;
#       disable-history: false;
#       hide-scrollbar: true;
#       display-drun: "   Apps ";
#       display-run: "   Run ";
#       display-window: " 󰕰  Window";
#       display-Network: " 󰤨  Network";
#       sidebar-mode: true;
#   }
# '';
    extraConfig = {
      modi = "run,drun,window";
      icon-theme = "Oranchelo";
      show-icons = true;
      terminal = "alacritty";
      drun-display-format = "{icon} {name}";
      location = 0;
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "   Apps ";
      display-run = "   Run ";
      display-window = " 󰕰  Window";
      display-network = " 󰤨  Network";
      sidebar-mode = true;
    };
  };
}

