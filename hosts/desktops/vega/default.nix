{
  imports = [
    ../default.nix
    ./hardware-configuration.nix

    ../../../modules/distributed/client.nix
    ../../../modules/distributed/machines

    ../../../modules/llms.nix
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
