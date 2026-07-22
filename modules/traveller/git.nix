{ config, lib, ... }:

let
  inherit (config) traveller;
in
{
  options.traveller = {
    git.user = lib.mkOption {
      type = lib.types.str;
    };

    github.user = lib.mkOption {
      type = lib.types.str;
    };
  };

  config.traveller.modules = [
    (
      { config, pkgs, ... }:

      {
        hjem.users.${traveller.user.name} = {
          packages = with pkgs; [
            git-lfs
            git-filter-repo
          ];

          rum.programs.git = {
            enable = true;

            settings = {
              user = {
                name = traveller.git.user;
                inherit (traveller) email;
                signingkey = config.age.secrets.${traveller.keys.private}.path;
              };

              commit.gpgsign = true;
              gpg.format = "ssh";

              github.user = traveller.github.user;

              color.ui = true;
              core.editor = "nvim";

              pull.rebase = true;
              push.autoSetupRemote = true;

              init.defaultBranch = "main";

              # TODO: change to /etc/nixos
              safe.directory = "~/nixos";

              alias = {
                graph = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
              };
            };
          };
        };
      }
    )
  ];
}
