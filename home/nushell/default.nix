{
  programs.nushell = {
    enable = true;

    configFile.source = ../../dots/nushell/config.nu;
    envFile.source = ../../dots/nushell/env.nu;
  };
}
