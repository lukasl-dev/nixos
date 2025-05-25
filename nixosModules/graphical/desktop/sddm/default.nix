{
  inputs,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  wayland = config.programs.hyprland.enable;

  where-is-my-sddm-theme =
    inputs.catppuccin-where-is-my-sddm-theme.packages.${pkgs-unstable.stdenv.hostPlatform.system}.default;
in
{
  services.displayManager.sddm = {
    enable = true;

    wayland.enable = wayland;

    theme = "where_is_my_sddm_theme";
    package = pkgs.kdePackages.sddm;
  };
  catppuccin.sddm.enable = false;

  environment.systemPackages = [
    (where-is-my-sddm-theme)
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      font = "Noto Sans";
      fontSize = "9";
      background = "${../../../../wallpapers/10.png}";
      loginBackground = true;
    })
  ];
}
