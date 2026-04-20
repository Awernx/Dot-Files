#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# --------------------------
# FISH shell customizations

# Don't load this script for non-interactive shells
status is-interactive; or exit 0

set --export fish_color_cwd brcyan
set --export --universal GIT_REPOS       $HOME/Workspace/Dot-Files
set --export --universal XDG_CONFIG_HOME $HOME/.config
set --export --universal XDG_DATA_HOME   $HOME/.local/share
set --export --universal XDG_CACHE_HOME  $HOME/.cache

if not set -q HOST_FULL_NAME
    set --export --global HOST_FULL_NAME  (hostname -f)
    set --export --global HOST_SHORT_NAME (hostname -s)
end

############################################################################
## Abbreviations
############################################################################
abbr ..    'cd ..'
abbr ...   'cd ../..'
abbr ping  'ping -c 5'
abbr grep  'grep --color=auto'
abbr wget  'wget -c '

if type -q eza
  set --local LS_COMMAND eza -almM --classify=always --color-scale=size --group-directories-first --sort=name --time-style=long-iso
  alias l  "$LS_COMMAND"
  alias ll "$LS_COMMAND -ghU@"
  alias lt "$LS_COMMAND --tree"
else
  set --local LS_COMMAND (which ls) -AgFh --color=always --group-directories-first --time-style=long-iso
  alias l  "$LS_COMMAND"
  alias ll "$LS_COMMAND"
end

############################################################################
##  Aliases
############################################################################
alias ls      l
alias clear   '/usr/bin/clear; commandline -f repaint; terminal_colors'
alias ttymode 'set --export --global TTY_MODE 1'
alias guimode 'set --erase --global TTY_MODE'
alias root    'sudo -i'
alias de      'direnv edit .'
alias da      'direnv allow '
alias gs      'git status'
alias pull    'git pull'
alias gclean  'git fetch --prune'
alias path    'string join \n $PATH'

if type -q bat
    alias cat 'bat --plain --paging=never'
    alias bat 'bat --style=grid,numbers,header-filesize'

    set --export --universal MANROFFOPT "-c"
    set --export --universal MANPAGER   "sh -c 'col -bx | bat -l man -p'"

    abbr --add --position anywhere -- -h '-h | bat -plhelp'
    abbr --add --position anywhere -- --help '--help | bat -plhelp'
end

type -q zoxide; and alias cd z

if type -q yazi
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            cd -- "$cwd"
        end
        rm -f -- "$tmp"
        # Restore cursor to I-beam
        printf '\e[5 q'
    end
end

############################################################################
## Functions
############################################################################

## Bind Ctrl + L to clear screen and display greeting
bind \cl 'clear; echo'

function fish_prompt
  set --local last_run_command_status $status
  set --local FISH_INDICATOR 🐟
  set --local PROMPT_INDICATOR ' ➤ '

  if test -n "$TTY_MODE"
      set FISH_INDICATOR 'FISH'
      set PROMPT_INDICATOR ' >> '
  end

  printf "\n"

  set -q SSH_CLIENT SSH_TTY; and echo -ns (set_color --bold -b magenta brwhite) SSH (set_color normal) (set_color magenta)  (set_color normal) ' '

  echo -ns (set_color --bold brmagenta) $SHLVL (set_color normal)  ┊ (set_color --bold bryellow) $FISH_INDICATOR ' ' (set_color normal)
  echo -ns (set_color $fish_color_cwd) (pwd)
  test $last_run_command_status -gt 0; and echo -ns (set_color --bold $fish_color_error) " [$last_run_command_status]"
  echo -ns (set_color --bold brwhite) $PROMPT_INDICATOR (set_color normal)
end

function fish_right_prompt
    set -q SSH_CLIENT SSH_TTY; and echo -ns (set_color -o $fish_color_host_remote) $OS_ICON " $HOST_SHORT_NAME" (set_color normal)
end

function this
  echo -ns '        Host: ' (set_color -o) $HOST_FULL_NAME (set_color normal) \n
  echo -ns '          OS: ' (set_color -o) $OS (set_color normal) \n
  test -n "$BASE_OS"; and echo -ns '     Base OS: ' (set_color -o) $BASE_OS (set_color normal) \n
  echo -ns 'Architecture: ' (set_color -o) (uname -m) (set_color normal) \n
  echo -ns '      Kernel: ' (set_color -o) (uname -sr) (set_color normal) \n
  echo -ns '       Shell: ' (set_color -o) '🐟 Fish ' $FISH_VERSION (set_color normal) \n
end

function fnd
    test (count $argv) -gt 0; and find . -iname "*$argv*" -type f -exec printf '"%s"\n' {} \;
end

function update
    set -q GIT_REPOS; or return

    for repo in $GIT_REPOS
        echo Updating $repo
        git -C $repo pull --ff-only
        echo
    end
end

function fish_title
    # Override fish's default 'pwd' behavior
end

function fish_greeting
    # Skip if running under SSH session
    set -q SSH_CLIENT SSH_TTY; and return
    terminal_colors
end

function terminal_colors
    set -q LIGHT_PROMPT; and return

    set -q HOST_BANNER; and begin
        type -q lolcat; and echo $HOST_BANNER | lolcat; or echo $HOST_BANNER
    end; or default_terminal_colors
end

function default_terminal_colors
  # Inspired by Ivo's ANSI Color script
  echo
  echo -ns (set_color red)   ' ██████  ' (set_color green)   ' ██████  ' (set_color yellow)   '   ██████' (set_color blue)   ' ██████  ' (set_color magenta)   '   ██████' (set_color cyan)   '   ██████' \n
  echo -ns (set_color red)   ' ████████' (set_color green)   ' ██    ██' (set_color yellow)   ' ██      ' (set_color blue)   ' ██    ██' (set_color magenta)   ' ██████  ' (set_color cyan)   ' ████████' \n
  echo -ns (set_color brred) ' ██  ████' (set_color brgreen) ' ██  ████' (set_color bryellow) ' ████    ' (set_color brblue) ' ████  ██' (set_color brmagenta) ' ████    ' (set_color brcyan) ' █████   ' \n
  echo -ns (set_color brred) ' ██    ██' (set_color brgreen) ' ██████  ' (set_color bryellow) ' ████████' (set_color brblue) ' ██████  ' (set_color brmagenta) ' ████████' (set_color brcyan) ' ██      ' \n
  echo -ns (set_color normal)
end
