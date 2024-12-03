{
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

  nixpkgs.config.allowUnfree = true;
}
