# env vars
$env.PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/go/bin")

# zoxide
zoxide init nushell --cmd cd | save -f ~/.zoxide.nu
