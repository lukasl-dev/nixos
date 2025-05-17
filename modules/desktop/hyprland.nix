{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  programs.hyprland = {
    enable = true;

    package = inputs.hyprland.packages.${pkgs-unstable.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs-unstable.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    xwayland.enable = true;
    withUWSM = true;
  };

  environment = {
    variables = {
      NIXOS_OZONE_WL = "1";
    };

    systemPackages = with pkgs; [
      wayland
      wayland-protocols

      egl-wayland

      (ueberzugpp.override { enableOpencv = false; }) # TODO: fix cuda issues

      hyprsunset
    ];
  };
}
