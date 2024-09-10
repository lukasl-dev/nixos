let
  username = "lukas-dev";
in
{
  programs.git = {
    enable = true;

    extraConfig = {
      color.ui = true;
      core.editor = "nvim";
      github.user = username;
      push.autoSetupRemote = true;
      pull.rebase = true;
    };

    userEmail = "git@lukasl.dev";
    userName = username;

    aliases = {
      graph = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
    };
  };
}
