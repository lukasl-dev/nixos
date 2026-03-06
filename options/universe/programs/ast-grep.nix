{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ ast-grep ];
}
