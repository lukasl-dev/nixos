{ config, ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      (config.universe.user.name)
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
  };
}
