if status is-interactive
    set --local brew_binaries "/opt/homebrew/bin"

    $brew_binaries/brew   shellenv  | source
    $brew_binaries/fzf    --fish    | source
    $brew_binaries/mcfly  init fish | source
    $brew_binaries/direnv hook fish | source
    $brew_binaries/zoxide init fish | source
end
