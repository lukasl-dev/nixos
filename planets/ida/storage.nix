{ lib, config, ... }:

let
  inherit (config.galaxy.lukasl-dev) backup;
in
{
  fileSystems."/mnt/external" = {
    device = "/dev/disk/by-uuid/F44EA6494EA60488";
    fsType = "ntfs3";
    options = [
      "nofail"
      "uid=0"
      "gid=0"
      "dmask=022"
      "fmask=133"
    ];
  };

  systemd.services.restic-server = lib.mkIf backup.enable {
    after = [ "mnt-external.mount" ];
    requires = [ "mnt-external.mount" ];
  };
}
