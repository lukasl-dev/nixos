{
  boot.loader = {
    efi.canTouchEfiVariables = true;
    limine = {
      enable = true;
      efiInstallAsRemovable = true;
    };
  };
}
