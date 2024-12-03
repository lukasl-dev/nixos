{
  imports = [
    ../default.nix

    ./ssh.nix
  ];

  networking.domain = "nodes.lukasl.dev";
}
