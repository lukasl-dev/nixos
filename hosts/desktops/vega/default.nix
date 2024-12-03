{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  import = [ ../default.nix ];

  networking.hostName = "vega";

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

  home-manager.users.lukas = import ../../../home/desktop { inherit inputs pkgs pkgs-unstable; };
}
