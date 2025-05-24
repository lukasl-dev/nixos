{ meta, ... }:

{
  programs.git = {
    enable = true;

    userEmail = "git@${meta.domain}";
    userName = meta.git.username;

    delta.enable = true;

    extraConfig = {
      github.user = meta.git.username;

      pull.rebase = true;
      push.autoSetupRemote = true;

      color.ui = true;
      core.editor = "nvim";

      safe.directory = "/nixos";

      # commit signing
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";

      # url = {
      #   "ssh://git@github.com/" = {
      #     insteadOf = "https://github.com/";
      #   };
      # };

      # merging
      merge.tool = "nvimdiff";
      mergetool = {
        nvimdiff.cmd = "nvim -d \$LOCAL \$REMOTE \$BASE \$MERGED";
        keepBackup = false;
      };
    };

    aliases = {
      graph = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
    };
  };
}
