{
  meta,
  inputs,
  pkgs,
  ...
}:

{
  imports = [ inputs.nix-ld.nixosModules.nix-ld ];

  system.stateVersion = "24.05";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      (meta.user.name)
    ];

    # binary cache
    substituters = [ "https://nix.lukasl.dev" ];
    trusted-public-keys = [ "nix.lukasl.dev:tKOhI7ckbT2uexK4/surblHqzPLHWf3mkm+87dewlu0=%" ];
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.nix-ld = {
    enable = true;
    dev.enable = false;
  };

  environment.systemPackages = with pkgs; [
    # nix language server
    nixd
    nixfmt-rfc-style
  ];
}
