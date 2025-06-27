{
  meta,
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  imports = [
    ../../../presets/desktop/nixos
    ./hardware-configuration.nix

    ../../../nixosModules/nixos/distributed/client.nix
    ../../../nixosModules/nixos/distributed/machines/default.nix

    ../../../nixosModules/gaming/gamemode.nix
    ../../../nixosModules/gaming/steam.nix

    ../../../nixosModules/hardware/gpus/nvidia.nix

    ../../../nixosModules/system/bluetooth.nix

    ../../../nixosModules/ollama.nix
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
