{
  config,
  inputs,
  ...
}:

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

  nixpkgs = {
    config = {
      allowUnfree = true;
    };

    overlays = [
      inputs.nur.overlays.default
    ];
  };
}
