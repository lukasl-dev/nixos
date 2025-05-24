{
  imports = [
    ../default.nix
    ./hardware-configuration.nix

    ../../../nixosModules/nixos/distributed/client.nix
    ../../../nixosModules/nixos/distributed/machines

    ../../../nixosModules/llms.nix
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
}
