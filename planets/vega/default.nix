{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./audio.nix
    ./nvidia.nix
    ./oom.nix
  ];

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernelModules = [
      "nct6683"
      "nct6775"
      "coretemp"
    ];
    extraModprobeConfig = ''
      options nct6683 force=1
    '';
    kernel.sysctl = {
      "user.max_user_namespaces" = 15000;
    };
    loader = {
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        efiInstallAsRemovable = true;
      };
    };
    supportedFilesystems.ntfs = true;
  };

  planet = {
    name = "vega";
    timeZone = "Europe/Vienna";
    stateVersion = "25.05";

    hardware = {
      bluetooth.enable = true;

      nvidia = {
        enable = true;
        cuda = true;
      };
    };

    display = {
      enable = true;

      hyprland = {
        enable = true;
        monitors = [
          {
            output = "DP-1";
            mode = "1920x1080@239.96";
            position = "0x0";
            scale = 1;
          }
          {
            output = "HDMI-A-1";
            mode = "1920x1080@74.973";
            position = "1920x0";
            scale = 1;
          }
        ];
      };
    };

    programs = {
      anki.enable = true;
      uxplay.enable = true;
    };

    services = {
      flatpak.enable = true;
      printing.enable = true;
    };

    networking = {
      dns.discoverable = true;
      mullvad.enable = true;
    };

    gaming = {
      enable = true;

      steam.enable = true;
      minecraft.enable = true;
      r2modman.enable = true;
    };
  };

  environment.systemPackages = [
    # nvidia/cuda build
    (pkgs.unstable.llama-cpp.override { cudaSupport = true; })

    # provides `hf download`
    (pkgs.python313.withPackages (ps: [
      ps.huggingface-hub
      ps.hf-transfer
    ]))
  ];

  environment.sessionVariables = {
    HF_HUB_ENABLE_HF_TRANSFER = "1";
  };
}
