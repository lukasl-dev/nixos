{ meta, ... }:

{
  services.xserver = {
    enable = true;

    xkb = {
      layout = meta.keyboard.layout;
      variant = meta.keyboard.variant;
    };

    displayManager = {
      lightdm.enable = false;
      startx.enable = true;
    };
  };
}
