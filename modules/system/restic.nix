{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ restic ];
}
