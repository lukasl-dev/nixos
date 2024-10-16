{ pkgs, ... }:

{
  imports = [
    ./fonts.nix
    ./i18n.nix
    ./users.nix
    ./shell.nix

    ../../modules/bluetooth.nix
    ../../modules/cloudflare_dns.nix
    ../../modules/docker.nix
    ../../modules/nix-ld.nix
    ../../modules/onepassword.nix
    ../../modules/localsend.nix
    ../../modules/udiskie.nix
  ];

  system.stateVersion = "24.05";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "lukas"
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  networking.firewall.enable = true;

  catppuccin = {
    enable = true;

    flavor = "mocha";
  };

  environment.systemPackages = with pkgs; [
    # nix language server
    nixd
    nixfmt-rfc-style
  ];
}
