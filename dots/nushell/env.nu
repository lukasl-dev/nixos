def create_left_prompt [] {
  let dir = match (do --ignore-shell-errors { $env.PWD | path relative-to $nu.home-path }) {
    null => $env.PWD
      '' => '~'
      $relative_pwd => ([~ $relative_pwd] | path join)
  }

  let path_color = (if (is-admin) { ansi "#f38ba8" } else { ansi "#eba0ac" })
    let separator_color = (if (is-admin) { ansi "#f38ba8" } else { ansi "#eba0ac" })
    let path_segment = $"($path_color)($dir)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

def create_right_prompt [] {
    let git_branch = (do {
        git rev-parse --abbrev-ref HEAD
    } | complete)

    let branch_segment = if $git_branch.exit_code == 0 {
        let branch = ($git_branch.stdout | str trim)
        ([
            (ansi reset)
            (ansi "#b4befe")
            "("
            $branch
            ")"
        ] | str join | str replace --regex --all "([/-])" $"(ansi green)${1}(ansi magenta)")
    } else {
        "" 
    }

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $branch_segment] | str join | str trim)
}


$env.PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/go/bin")


$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }


$env.PROMPT_INDICATOR = {|| (ansi "#eba0ac") + "> " + (ansi reset) }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| (ansi "#eba0ac") + "> " + (ansi reset) }
$env.PROMPT_INDICATOR_VI_INSERT = {|| (ansi "#eba0ac") + ": " + (ansi reset) }
$env.PROMPT_INDICATOR_MULTILINE_INDICATOR = {|| (ansi "#eba0ac") + "::: " + (ansi reset) }


zoxide init nushell --cmd cd | save -f ~/.zoxide.nu
