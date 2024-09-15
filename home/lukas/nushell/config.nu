let carapace_completer = {|spans|
    carapace $spans.0 nushell ...$spans | from json
}

let fish_completer = {|spans|
    fish --command $'complete "--do-complete=($spans | str join " ")"'
    | $"value(char tab)description(char newline)" + $in
    | from tsv --flexible --no-infer
}

let zoxide_completer = {|spans|
    let query = $spans | skip 1 | str join ' '
    let zoxide_results = if $query == '' {
        zoxide query -l | lines | where {|x| $x != $env.PWD}
    } else {
        zoxide query -l $query | lines | where {|x| $x != $env.PWD}
    }
    let ls_results = if $query == '' {
        ls | get name | where {|x| ($x | path type) == 'dir'}
    } else {
        let target_dir = if ($query | path exists) and ($query | path type) == 'dir' {
            $query
        } else {
            $env.PWD
        }
        ls $target_dir | get name | where {|x| ($x | path type) == 'dir'}
    }
    $zoxide_results | append $ls_results | uniq
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
