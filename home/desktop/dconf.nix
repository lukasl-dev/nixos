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
    pkgs.dconf-editor
    adw-gtk3
  ];
}
