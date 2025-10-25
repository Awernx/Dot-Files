#!/usr/bin/env bash

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# -----------------------------------------
# Script that will drop to fish shell on interactive login, but continue with bash for non-interactive sessions.
# Source this file in your .bashrc - preferably at the beginning

# Credit and reference: https://wiki.archlinux.org/title/Fish#Setting_fish_as_interactive_shell_only

if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} == 1 ]]
then
    shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
    exec fish $LOGIN_OPTION
fi