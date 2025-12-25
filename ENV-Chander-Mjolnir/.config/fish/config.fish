if status is-interactive
    /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
    fzf --fish                                   | source
    mcfly init fish                              | source
    direnv hook fish                             | source
    zoxide init fish                             | source
end
