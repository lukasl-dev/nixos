let
  uuid = "37ab2267-35b2-4526-aeba-a8d21d468e7e";
in
{
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
      enableCryptodisk = true;
    };

    initrd = {
      secrets."/boot/crypto_keyfile.bin" = null;

      luks.devices = {
        "luks-${uuid}" = {
          device = "/dev/disk/by-uuid/${uuid}";
          keyFile = "/boot/crypto_keyfile.bin";
        };
        "luks-a0883504-67d0-452d-9668-2227dd6090e7".keyFile = "/boot/crypto_keyfile.bin";
      };
    };
  };

  # boot.initrd.luks.devices."luks-37ab2267-35b2-4526-aeba-a8d21d468e7e".device = "/dev/disk/by-uuid/37ab2267-35b2-4526-aeba-a8d21d468e7e";
  # # Setup keyfile
  # boot.initrd.secrets = {
  #   "/boot/crypto_keyfile.bin" = null;
  # };
  #
  # boot.loader.grub.enableCryptodisk = true;
  #
  # boot.initrd.luks.devices."luks-a0883504-67d0-452d-9668-2227dd6090e7".keyFile = "/boot/crypto_keyfile.bin";
  # boot.initrd.luks.devices."luks-37ab2267-35b2-4526-aeba-a8d21d468e7e".keyFile = "/boot/crypto_keyfile.bin";
}
