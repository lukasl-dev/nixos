{ pkgs, ... }:

{
  vim = {
    extraPackages = with pkgs; [
      gcc
      clang
    ];

    languages.clang.enable = true;
  };
}
