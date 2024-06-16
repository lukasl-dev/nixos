{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.xserver.displayManager.lightdm.enable = false;
}
