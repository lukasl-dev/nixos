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

  environment.systemPackages = with pkgs; [
    (catppuccin-sddm.override {
        flavor = "mocha";
        font  = "Noto Sans";
        fontSize = "9";
        background = "${../../wallpapers/1.png}";
        loginBackground = true;
    })
  ];

  services.displayManager.sddm = {
    enable = true;
    theme = "catppuccin-mocha";
    package = pkgs.kdePackages.sddm;
  };
}
