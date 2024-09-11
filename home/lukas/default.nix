{ pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./development/bun.nix
    ./development/elixir.nix
    ./development/erlang.nix
    ./development/gleam.nix
    ./development/go.nix
    ./development/java.nix
    ./development/node.nix
    ./development/python.nix
    ./development/rust.nix
    ./development/texlive.nix
    ./development/zig.nix

    ./gaming/lutris.nix
    ./gaming/minecraft.nix
    ./gaming/proton-ge.nix
    ./gaming/wine.nix

    ./programs/easyeffects
    ./programs/chromium.nix
    ./programs/gpg.nix
    ./programs/newsflash.nix
    ./programs/sioyek.nix

    ./system/desktop/hyprland
    ./system/desktop/waybar
    ./system/desktop/dconf.nix
    ./system/desktop/dunst.nix
    ./system/desktop/gtk.nix
    ./system/desktop/rofi.nix

    ./system/editors/nvim

    ./system/shells/nushell
    ./system/shells/zsh

    ./system/terminals/alacritty.nix

    ./system/tools/bat.nix
    ./system/tools/btop.nix
    ./system/tools/carapace.nix
    ./system/tools/dir-env.nix
    ./system/tools/fastfetch.nix
    ./system/tools/fzf.nix
    ./system/tools/gh.nix
    ./system/tools/git.nix
    ./system/tools/hyperfine.nix
    ./system/tools/just.nix
    ./system/tools/mpv.nix
    ./system/tools/ranger.nix
    ./system/tools/ripgrep.nix
    ./system/tools/speedtest-cli.nix
    ./system/tools/tree.nix
    ./system/tools/yt-dlp.nix
    ./system/tools/zip.nix
    ./system/tools/zoxide.nix

    ./system/utils/xdg
    ./system/utils/udiskie.nix

    ./catppuccin.nix
  ];

  programs.home-manager.enable = true;

  home = {
    stateVersion = "24.05";

    username = "lukas";
    homeDirectory = "/home/lukas";
    packages = import ./packages.nix { inherit pkgs pkgs-unstable; };
  };
}
