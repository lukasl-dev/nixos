{
  meta,
  inputs,
  pkgs,
  ...
}:

{
  imports = [ inputs.nix-ld.nixosModules.nix-ld ];

  system.stateVersion = "24.11";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      (meta.user.name)
      "nixremote"
    ];

    # binary cache
    substituters = [
      "https://nix-community.cachix.org"
      "https://ghostty.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = meta.cuda;
  };

  programs.nix-ld = {
    enable = true;
    dev.enable = false;
  };

  environment.systemPackages = with pkgs; [
    # nix language server
    nixd
    nixfmt-rfc-style

    # nix-alien
    inputs.nix-alien.packages.${system}.nix-alien
  ];
}
