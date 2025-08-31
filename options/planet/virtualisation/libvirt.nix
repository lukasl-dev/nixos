{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  libvirt = config.planet.virtualisation.libvirt;
in
{
  options.planet.virtualisation.libvirt = {
    enable = lib.mkEnableOption "Enable libvirt";

    virt-manager = {
      enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable virt-manager";
        default = false;
        example = true;
      };
    };
  };

  config = lib.mkIf libvirt.enable (
    lib.mkMerge [
      {
        virtualisation = {
          libvirtd = {
            enable = true;
            qemu = {
              swtpm.enable = true;
              ovmf.packages = [ pkgs-unstable.OVMFFull.fd ];
            };
          };
          spiceUSBRedirection.enable = true;
        };
        environment = {
          systemPackages = [ pkgs-unstable.libvirt ];
          variables.LIBVIRT_DEFAULT_URI = "qemu:///system";
        };
      }
      (lib.mkIf libvirt.virt-manager.enable {
        programs.virt-manager.enable = true;
      })
    ]
  );
}
