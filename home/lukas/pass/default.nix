{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pass
    passExtensions.pass-otp
  ];
}
