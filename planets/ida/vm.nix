{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  # Bring in the QEMU VM module to expose config.system.build.vm
  imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];

  # Make the VM convenient to boot & test anywhere.
  virtualisation = {
    memorySize = 1024; # MB
    cores = 2;
    graphics = true; # set to false for a headless serial-only VM
    qemu = {
      package = pkgs.qemu; # multi-target qemu (works for aarch64 guest on x86_64 host)
    };
  };

  # Keep sops module loaded but override user passwords so secrets aren't needed to log in.

  # Override users defined in options/universe/user.nix to avoid SOPS during VM tests
  users.users = {
    root = {
      hashedPasswordFile = lib.mkForce null;
      initialPassword = "root";
    };
    "${config.universe.user.name}" = {
      hashedPasswordFile = lib.mkForce null;
      initialPassword = "vm";
    };
  };
}
