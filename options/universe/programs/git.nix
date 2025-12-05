{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  git = config.universe.git;
in
{
  options.universe.git = {
    user = lib.mkOption {
      type = lib.types.submodule {
        options = {
          email = lib.mkOption {
            type = lib.types.str;
            description = "Email address used for git commits.";
            default = "";
            example = "git@lukasl.dev";
          };

          name = lib.mkOption {
            type = lib.types.str;
            description = "Username used for git commits.";
            default = "";
            example = "lukasl-dev";
          };
        };
      };
      default = { };
    };
  };

  config = {
    assertions = [
      {
        assertion = git.user.email != "";
        message = "🪐 Please define 'universe.git.user.email'.";
      }
      {
        assertion = git.user.name != "";
        message = "🪐 Please define 'universe.git.user.name'.";
      }
    ];

    environment.systemPackages = with pkgs-unstable; [
      git-lfs
      git-filter-repo
    ];

    universe.hm = [
      {
        programs = {
          git = {
            enable = true;

            settings = {
              user = { inherit (git.user) name email; };

              aliases = {
                graph = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
              };

              github.user = git.user.name;

              color.ui = true;
              core.editor = "nvim";

              pull.rebase = true;
              push.autoSetupRemote = true;
              init.defaultBranch = "master";

              safe.directory = "/nixos";

              commit.gpgsign = true;
              gpg.format = "ssh";
              user.signingkey = "~/.ssh/id_ed25519.pub";
            };
          };

          # TODO: move outside
          delta = {
            enable = true;

            enableGitIntegration = true;
          };
        };

        home.packages = [ pkgs.git-lfs ];
      }
    ];
  };
}
