{ meta, ... }:
{
  programs.git = {
    enable = true;
    config = {
      safe.directory = [
        "/home/${meta.user.name}/nixos"
      ];
    };
  };
}
