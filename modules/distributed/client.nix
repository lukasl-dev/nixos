{ config, ... }:

{
  nix = {
    distributedBuilds = true;

    settings = {
      builders-use-substitutes = true;
    };
  };
}
