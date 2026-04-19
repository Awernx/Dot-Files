#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ------------------------------------
# Chander's FISH shell customizations

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end

set --export fish_color_cwd brcyan

# XDG (Just in case they're not set already)
set --export --universal XDG_CONFIG_HOME $HOME/.config
set --export --universal XDG_DATA_HOME   $HOME/.local/share
set --export --universal XDG_CACHE_HOME  $HOME/.cache
set --export --universal GIT_REPOS       $HOME/Workspace/Dot-Files

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

if type -q bat
    alias cat 'bat --plain --paging=never'
    alias bat 'bat --style=grid,numbers,header-filesize'

    set --export --universal MANROFFOPT "-c"
    set --export --universal MANPAGER   "sh -c 'col -bx | bat -l man -p'"

    abbr --add --position anywhere -- -h '-h | bat -plhelp'
    abbr --add --position anywhere -- --help '--help | bat -plhelp'
end

if type -q zoxide
    alias cd z
end

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

  set -q SSH_CLIENT SSH_TTY; and echo -ns (set_color --bold -b magenta white) SSH (set_color normal) (set_color magenta)  (set_color normal) ' '

  echo -ns (set_color --bold brmagenta) $SHLVL (set_color normal)  ┊ (set_color $fish_color_operator) $FISH_INDICATOR ' '
  echo -ns (set_color $fish_color_cwd) (pwd)

  if [ $last_run_command_status -gt 0 ]
      echo -ns (set_color --bold $fish_color_error) ' ' [$last_run_command_status]
  end

  echo -ns (set_color brwhite) $PROMPT_INDICATOR (set_color normal)
end

function fish_right_prompt
    if not set -q LIGHT_PROMPT
        echo -ns (set_color -o $fish_color_host_remote) "$OS_ICON $HOST_SHORT_NAME" (set_color normal)
    end
end

function this
  echo -ns '        Host: ' (set_color -o) $HOST_FULL_NAME (set_color normal) \n
  echo -ns '          OS: ' (set_color -o) $OS (set_color normal) \n

  if test -n "$BASE_OS"
    echo -ns '     Base OS: ' (set_color -o) $BASE_OS (set_color normal) \n
  end

  echo -ns 'Architecture: ' (set_color -o) (uname -m) (set_color normal) \n
  echo -ns '      Kernel: ' (set_color -o) (uname -sr) (set_color normal) \n
  echo -ns '       Shell: ' (set_color -o) '🐟 Fish ' $FISH_VERSION (set_color normal) \n
end

function path
  for path_item in $PATH
    echo $path_item
  end
end

function fnd
  if count $argv > /dev/null
    find . -iname "*$argv*" -type f  -exec printf '"%s"\n' {} \;
  end
end

function update
    if test -z "$GIT_REPOS"
        echo 'GIT_REPOS env variable is empty; nothing to update'
        exit 0
    end

    for git_repo in $GIT_REPOS
        echo Updating $git_repo
        git -C $git_repo pull --ff-only
        echo
    end
end

function register_script
    if count $argv > /dev/null
        set --local script_full_path (readlink -f $argv)
        set --local script_name (basename $script_full_path)

        echo "Registering '$script_name' with 🐟"
        ln -sf $script_full_path ~/.config/fish/conf.d/
    end
end

function fish_title
    # Override default fish's pwd behavior
end

function fish_greeting
    # Skip and return if logging in under a remote SSH session
    set -q SSH_CLIENT SSH_TTY; and return

    terminal_colors
end

function terminal_colors
    # If LIGHT_PROMPT is requested, skip banner rendering and return
    set -q LIGHT_PROMPT; and return

    set -q HOST_BANNER; and begin
        type -q lolcat; and echo $HOST_BANNER | lolcat; or echo $HOST_BANNER
    end; or default_terminal_colors
end

function default_terminal_colors
  # Inspired by Ivo's ANSI Color script
  # Source: http://crunchbang.org/forums/viewtopic.php?pid=134749#p134749
  echo
  echo -ns (set_color red)   ' ██████  ' (set_color green)   ' ██████  ' (set_color yellow)   '   ██████' (set_color blue)   ' ██████  ' (set_color magenta)   '   ██████' (set_color cyan)   '   ██████' \n
  echo -ns (set_color red)   ' ████████' (set_color green)   ' ██    ██' (set_color yellow)   ' ██      ' (set_color blue)   ' ██    ██' (set_color magenta)   ' ██████  ' (set_color cyan)   ' ████████' \n
  echo -ns (set_color brred) ' ██  ████' (set_color brgreen) ' ██  ████' (set_color bryellow) ' ████    ' (set_color brblue) ' ████  ██' (set_color brmagenta) ' ████    ' (set_color brcyan) ' █████   ' \n
  echo -ns (set_color brred) ' ██    ██' (set_color brgreen) ' ██████  ' (set_color bryellow) ' ████████' (set_color brblue) ' ██████  ' (set_color brmagenta) ' ████████' (set_color brcyan) ' ██      ' \n
  echo -ns (set_color normal)
end
