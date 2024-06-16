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
    };

    userEmail = "git@lukasl.dev";
    userName = username;
  };
}
