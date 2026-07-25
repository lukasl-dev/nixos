let
  secondaryLuksUuid = "37ab2267-35b2-4526-aeba-a8d21d468e7e";
  rootLuksUuid = "a0883504-67d0-452d-9668-2227dd6090e7";
in
{
  boot = {
    loader.grub = {
      enable = true;
      devices = [ "/dev/vda" ];
      enableCryptodisk = true;
    };

    initrd = {
      secrets."/boot/crypto_keyfile.bin" = null;

      luks.devices = {
        "luks-${secondaryLuksUuid}" = {
          device = "/dev/disk/by-uuid/${secondaryLuksUuid}";
          keyFile = "/boot/crypto_keyfile.bin";
        };
        "luks-${rootLuksUuid}".keyFile = "/boot/crypto_keyfile.bin";
      };
    };
  };
}
