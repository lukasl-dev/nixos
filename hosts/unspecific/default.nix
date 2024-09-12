{ pkgs, ... }:

{
  imports = [
    ../../modules/catppuccin.nix
    ../../modules/nix.nix
    ../../modules/nix-ld.nix

    ../../modules/programs/onepassword.nix

    ../../modules/system/fonts.nix
    ../../modules/system/i18n.nix
    ../../modules/system/users.nix

    ../../modules/system/virtualisation/docker.nix
  ];

  environment.systemPackages = with pkgs; [
    nixd
    nixfmt-rfc-style
  ];
}
