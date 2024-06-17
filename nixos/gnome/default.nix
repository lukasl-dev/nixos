{ pkgs, ... }:

{
  services.gnome = {
    gnome-keyring.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gnome.gnome-keyring
  ];

  programs.seahorse.enable = true;
}
