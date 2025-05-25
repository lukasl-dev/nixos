{
  meta,
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  imports = [
    ../../../presets/laptop/nixos
    ./hardware-configuration.nix

    ../../../nixosModules/hardware/gpus/nvidia.nix
  ];

  boot = {
    kernelModules = [
      "nct6775"
      "coretemp"
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = {
      ntfs = true;
    };
  };

  home-manager.users.${meta.user.name} = import ../home {
    inherit inputs pkgs pkgs-unstable;
  };
}
