{ meta, pkgs, ... }:

{
  system.stateVersion = "25.05";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      (meta.user.name)
      "build"
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = meta.cuda;
  };

  environment.systemPackages = with pkgs; [
    # nix language server
    nixd
    nixfmt-rfc-style
  ];
}
