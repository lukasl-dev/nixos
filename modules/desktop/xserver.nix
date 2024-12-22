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

    # extraConfig = ''
    #   Section "Device"
    #       Identifier "Device0"
    #       Driver "nvidia"
    #       VendorName "NVIDIA Corporation"
    #       Option "Coolbits" "4"
    #   EndSection
    # '';
  };
}
