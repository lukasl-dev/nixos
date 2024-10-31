{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 8;
          y = 8;
        };
      };
      shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [
          "-l"
          "-c"
          "tmux attach-session ; new-window || tmux"
        ];
      };
    };
  };
}
