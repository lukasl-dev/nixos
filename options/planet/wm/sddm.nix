{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;

  where-is-my-sddm-theme = inputs.catppuccin-where-is-my-sddm-theme.packages.${system}.default;
in
lib.mkIf config.planet.wm.enable {
  services.displayManager = {
    defaultSession = lib.mkIf config.planet.wm.hyprland.enable "hyprland-uwsm";

    sddm = {
      enable = true;

      wayland.enable = config.planet.wm.hyprland.enable;

      theme = "where_is_my_sddm_theme";
      package = pkgs.kdePackages.sddm;
    };
  };

  catppuccin.sddm.enable = false;

  services.displayManager.preStart = ''
    ${pkgs.coreutils}/bin/sleep 2
  '';

  environment.systemPackages = [
    where-is-my-sddm-theme
    (pkgs.catppuccin-sddm.override {
      inherit (config.catppuccin) flavor;
      font = "Noto Sans";
      fontSize = "9";
      background = "${../../../wallpapers/10.png}";
      loginBackground = true;
    })
  ];
}
