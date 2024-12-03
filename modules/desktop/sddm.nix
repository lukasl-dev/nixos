{ pkgs, ... }:

{
  services.displayManager.sddm = {
    enable = true;

    theme = "catppuccin-mocha";
    package = pkgs.kdePackages.sddm;
  };

  environment.systemPackages = [
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      font = "Noto Sans";
      fontSize = "9";
      background = "${../../wallpapers/10.png}";
      loginBackground = true;
    })
  ];
}
