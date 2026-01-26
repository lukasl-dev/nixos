{
  config,
  pkgs,
  ...
}:

let
  user = config.universe.user;

  homeDir = config.home-manager.users.${user.name}.home.homeDirectory;
in
{
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "nvim-copy";
      text = # bash
        ''
          rm -rf ${homeDir}/.config/nvim
          cp ${homeDir}/nixos/options/universe/nvim ${homeDir}/.config/ -r
        '';
    })
    (pkgs.writeShellApplication {
      name = "nvim-restore";
      text = # bash
        ''
          cp ${../nvim} ${homeDir}/.config/ -r
        '';
    })
    (pkgs.writeShellApplication {
      name = "nvim-unswap";
      text = # bash
        ''
          rm -rf ${homeDir}/.local/state/nvim/swap
        '';
    })
  ];

  universe.hm = [
    {
      programs.neovim = {
        enable = true;

        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        extraPackages = with pkgs.unstable; [
          # tools
          sqlite
          gcc
          gnumake
          ripgrep

          copilot-language-server

          # nix
          nixd
          nixfmt-rfc-style

          codex

          # python
          ruff
          uv
          python312Packages.grip
          python312Packages.pylatexenc

          # rust
          rustc
          cargo

          # lua
          lua-language-server

          # bash
          bash-language-server

          # nodejs
          nodejs
        ];
      };

      home.file.".config/nvim" = {
        enable = true;
        source = ../nvim;
        target = ".config/nvim";
      };
    }
  ];
}
