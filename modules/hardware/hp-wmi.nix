{ pkgs, ... }:

{
  boot.kernelModules = [ "hp-wmi" ];

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "hp_wmi_boost_fan";
      runtimeInputs = [ pkgs.coreutils ]; # Provides cat, tr, echo
      text = builtins.readFile ../../scripts/hp_wmi_boost_fan.sh;
    })
  ];
}
