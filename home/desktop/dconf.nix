{ pkgs, ... }:

{
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  home.packages = with pkgs; [
    gnome.dconf-editor
    adw-gtk3
  ];
}
