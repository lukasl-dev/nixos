$env.config = {
  show_banner: false

  edit_mode: vi
}

use ./themes/catppuccin_mocha.nu
$env.config = ($env.config | merge {color_config: (catppuccin_mocha)})

source ~/.zoxide.nu
