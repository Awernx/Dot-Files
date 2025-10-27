if status is-interactive
    fzf --fish                        | source 
    mcfly init fish                   | source
    direnv hook fish                  | source
    zoxide init fish                  | source
end
