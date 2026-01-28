{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs.unstable; [
    nixd
    nixfmt
  ];
}
