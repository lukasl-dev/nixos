return {
  "williamboman/mason.nvim",

  cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },

  opts = {
    registries = {
      "github:nvim-java/mason-registry",
      "github:mason-org/mason-registry",
    },

    ui = {
      icons = {
        package_pending = " ",
        package_installed = " ",
        package_uninstalled = " ",
      },
    },

    max_concurrent_installers = 10,
  },
}
