{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vulkan-headers
    vulkan-loader
    vulkan-tools
  ];
}
