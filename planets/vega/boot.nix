{
  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernelModules = [
      "nct6683"
      "nct6775"
      "coretemp"
    ];
    extraModprobeConfig = ''
      options nct6683 force=1
    '';
    kernel.sysctl = {
      "user.max_user_namespaces" = 15000;
    };
    loader = {
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        efiInstallAsRemovable = true;
      };
    };
    supportedFilesystems.ntfs = true;
  };
}
