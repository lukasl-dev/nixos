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

      let
        yaml = pkgs.formats.yaml { };
      in
      {
        hjem.users.${traveller.user.name} = {
          packages = with pkgs; [
            difftastic
            gh
            gh-dash
            git-lfs
            git-filter-repo
          ];

          xdg = {
            config.files = {
              "gh/config.yml".source = yaml.generate "gh-config.yml" {
                version = "1";
              };
              "gh-dash/config.yml".source = yaml.generate "gh-dash-config.yml" { };
            };

            data.files."gh/extensions".source = pkgs.linkFarm "gh-extensions" [
              {
                name = pkgs.gh-dash.pname;
                path = "${pkgs.gh-dash}/bin";
              }
            ];
          };

          rum.programs.git = {
            enable = true;

            integrations.difftastic.enable = true;

            settings = {
              user = {
                name = traveller.git.user;
                inherit (traveller) email;
                signingkey = config.age.secrets.${traveller.keys.private}.path;
              };

              commit.gpgsign = true;
              gpg.format = "ssh";

              github.user = traveller.github.user;

              credential = {
                "https://github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
                "https://gist.github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
              };

              color.ui = true;
              core.editor = "nvim";

              pull.rebase = true;
              push.autoSetupRemote = true;

              init.defaultBranch = "main";

              # TODO: change to /etc
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
