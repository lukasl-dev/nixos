{ meta, ... }:

{
  nix.buildMachines = [
    {
      hostName = "pollux.nodes.${meta.domain}";
      sshUser = "build";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 2;
      speedFactor = 2;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      mandatoryFeatures = [ ];
    }
  ];
}
