{ pkgs, ... }:

{
  vim = {
    extraPackages = with pkgs; [ wl-clipboard ];

    clipboard = {
      enable = true;
      providers = {
        wl-copy.enable = true;
      };
    };
  };
}
