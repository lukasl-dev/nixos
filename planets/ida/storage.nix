{ lib, config, ... }:

let
  inherit (config.galaxy.lukasl-dev) backup;
  externalStorageGroup = "external-storage";
  externalStorageGid = 989;
in
{
  fileSystems."/mnt/external" = {
    device = "/dev/disk/by-uuid/F44EA6494EA60488";
    fsType = "ntfs3";
    options = [
      "nofail"
      "uid=0"
      "gid=${toString externalStorageGid}"
      "dmask=002"
      "fmask=113"
    ];
  };

  users.groups.${externalStorageGroup}.gid = externalStorageGid;

  users.users.restic.extraGroups = lib.mkIf backup.enable [ externalStorageGroup ];

  systemd.services.restic-rest-server = lib.mkIf backup.enable {
    after = [ "mnt-external.mount" ];
    requires = [ "mnt-external.mount" ];
  };
}
