{ pkgs, ... }:

{
  home.packages = with pkgs; [ erlang ];
}
