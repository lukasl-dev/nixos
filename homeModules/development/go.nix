{ pkgs-unstable, ... }:

{
  programs.go = {
    enable = true;
    package = pkgs-unstable.go_1_24;
  };

  home.packages = [

    pkgs-unstable.delve
    pkgs-unstable.gopls
    pkgs-unstable.nilaway
  ];
}
