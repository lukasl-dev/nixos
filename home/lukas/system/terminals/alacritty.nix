# { pkgs, ... }:

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
      # shell = {
      #   program = "${pkgs.nushell}/bin/nu";
      #   args = [
      #     "-e"
      #     "${pkgs.zellij}/bin/zellij"
      #   ];
      # };
    };
  };
}
