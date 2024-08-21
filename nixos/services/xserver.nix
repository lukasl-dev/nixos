{
  services.xserver = {
    enable = true;

    videoDrivers = [ "nvidia" ]; # TODO: configurable

    xkb = {
      layout = "us";
      variant = "";
    };

    displayManager = {
      lightdm.enable = false; # TODO: configurable
      startx.enable = true; # TODO: configurable
    };

    screenSection = ''
      Option "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      Option "AllowIndirectGLXProtocol" "off"
      Option "TripleBuffer" "on"
    '';
  };
}
