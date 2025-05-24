{
  programs.bash = {
    enable = true;

    shellAliases = import ./aliases.nix;
  };
}
