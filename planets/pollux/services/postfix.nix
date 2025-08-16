{ config, ... }:

let
  domain = config.universe.domain;
in
{
  services.postfix = {
    enable = true;

    domain = domain;
  };
}
