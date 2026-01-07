{ pkgs, ... }:
{
  universe.hm = [
    {
      programs.bash = {
        enable = true;

        shellAliases = import ./aliases.nix { inherit pkgs; };
      };
    }
  ];
}
