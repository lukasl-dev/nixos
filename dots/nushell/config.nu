let carapace_completer = {|spans|
    carapace $spans.0 nushell ...$spans | from json
}

let fish_completer = {|spans|
    fish --command $'complete "--do-complete=($spans | str join " ")"'
    | $"value(char tab)description(char newline)" + $in
    | from tsv --flexible --no-infer
}

let zoxide_completer = {|spans|
    let query = ($spans | skip 1 | str join " ")
    let local_items = if ($query | is-empty) { 
        [] 
    } else { 
        ls -a 
        | where name != '.' and name != '..' 
        | get name 
        | where { |item| $item | str contains $query }
    }
    let zoxide_results = if ($query | is-empty) {
        zoxide query -l | lines
    } else {
        $spans | skip 1 | zoxide query -l ...$in | lines
    }
    let filtered_zoxide = $zoxide_results | where {|x| $x != $env.PWD and ($x | str contains $query) }
    let combined_results = ($local_items | append $filtered_zoxide | uniq)
    $combined_results
}

let external_completer = {|spans|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -i 0.expansion
    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }
    match $spans.0 {
        # fish completes commits and branch names in a nicer way
        git => $fish_completer
        __zoxide_z | __zoxide_zi => $zoxide_completer
        * => $carapace_completer
    } | do $in $spans
}

$env.config = {
  show_banner: false
  edit_mode: vi
  completions: {
    external: {
      enable: true
      completer: $external_completer
    }
  }
}

use ./themes/catppuccin_mocha.nu
$env.config = ($env.config | merge {color_config: (catppuccin_mocha)})

source ~/.zoxide.nu
