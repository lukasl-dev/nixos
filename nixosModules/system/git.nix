{ meta, pkgs, ... }:
{
  programs.git = {
    enable = true;
    config = {
      safe.directory = [
        "/home/${meta.user.name}/nixos"
      ];
    };
  };

  environment.systemPackages = [ pkgs.git-filter-repo ];
}
