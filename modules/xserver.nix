{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };

    displayManager = {
      lightdm.enable = false;
      startx.enable = true;
    };
  };
}
