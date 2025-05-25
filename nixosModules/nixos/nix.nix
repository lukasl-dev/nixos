{ meta, ... }:

{
  system.stateVersion = meta.stateVersion;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      (meta.user.name)
    ];
  };

  nix.nixPath = [
    "homeModules=${../../homeModules}"
  ];

  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = meta.cuda;
  };
}
