#!/usr/bin/env bash

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# -----------------------------------------
# Script that will continue with BASH for non-interactive sessions.
# But drop to Fish shell only if all of the following are true
# 1) On interactive login
# 2) Parent process is not Fish
#
# Source this file in your .bashrc - preferably at the beginning

# Credit and reference: https://wiki.archlinux.org/title/Fish#Setting_fish_as_interactive_shell_only

if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} == 1 ]]
then
    shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
    exec fish $LOGIN_OPTION
fi
