{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;

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

    winapps = {
      enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable winapps";
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
              # ovmf.packages = [ pkgs.unstable.OVMFFull.fd ];
            };
          };
          spiceUSBRedirection.enable = true;
        };

        environment = {
          systemPackages = [ pkgs.unstable.libvirt ];
          variables.LIBVIRT_DEFAULT_URI = "qemu:///system";
        };
      }
      (lib.mkIf libvirt.virt-manager.enable {
        programs.virt-manager.enable = true;
      })
      (lib.mkIf libvirt.winapps.enable {
        environment.systemPackages = [
          inputs.winapps.packages."${system}".winapps
          inputs.winapps.packages."${system}".winapps-launcher # optional

          pkgs.dialog
          pkgs.freerdp
        ];
      })
      # (
      #   let
      #     domains = libvirt.domains;
      #     names = builtins.attrNames domains;
      #   in
      #   lib.mkIf (domains != { }) {
      #     environment.etc = lib.foldl' (
      #       acc: name:
      #       let
      #         dom = domains.${name};
      #       in
      #       acc
      #       // {
      #         "libvirt/qemu/${name}.xml".source = dom.source;
      #       }
      #     ) { } names;
      #
      #     systemd.services = lib.foldl' (
      #       acc: name:
      #       let
      #         dom = domains.${name};
      #       in
      #       acc
      #       // {
      #         "libvirt-define-${name}" = {
      #           description = "Define libvirt domain ${name}";
      #           after = [ "libvirtd.service" ];
      #           requires = [ "libvirtd.service" ];
      #           wantedBy = [ "multi-user.target" ];
      #           serviceConfig = {
      #             Type = "oneshot";
      #             RemainAfterExit = true;
      #           };
      #           script = ''
      #             set -eu
      #             ${pkgs.unstable.libvirt}/bin/virsh define /etc/libvirt/qemu/${name}.xml
      #             ${lib.optionalString dom.autostart "${pkgs.unstable.libvirt}/bin/virsh autostart ${name}"}
      #           '';
      #         };
      #       }
      #     ) { } names;
      #   }
      # )
    ]
  );
}
