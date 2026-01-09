#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------------------------------
# Chander's FISH shell shortcuts for docker commands

# ======================================================================
# NOTE: All commands below need root access (sudo)
#       To avoid that, add current user to Docker group
#       Ref: https://docs.docker.com/engine/install/linux-postinstall/
# ======================================================================

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end

# QEMU is a type-2 hypervisor that allows you to run virtual machines on your host system.
# It can emulate a wide range of architectures, including x86 and ARM.
# The qemu-system-aarch64 package provides an AArch64 (ARM64) system emulator,
# which can be used to emulate an entire system, including the CPU and various peripheral devices.
# To build code on Raspberry Pi, QEMU can be used to simulate an AArch64 system on an x86 machine
abbr dqemu  'docker run --rm --privileged multiarch/qemu-user-static --reset -p yes'
abbr drm    'docker image rm --force' # Remove a specific image -> Pass image id as param

alias dclean 'docker image prune --force; docker container prune --force; docker network prune --force'
alias dpurge 'docker system prune --all --volumes --force'

# List all images and containers
function dl
    printf '📸 I M A G E S\n'
    printf '==========================================================================\n'
    docker images;

    printf '\n🐳 C O N T A I N E R S\n'
    printf '==========================================================================\n'
    docker container ls -a

    printf '\n🛜 N E T W O R K S\n'
    printf '==========================================================================\n'
    docker network ls
end

# List all docker shortcuts
function dhelp
    printf '\n🐳 DOCKER shorcut commands\n'
    printf '-------------------------------------------------------------\n'
    printf 'dl     --> Lists all images and containers \n'
    printf 'drm    --> Removes a specific image - Pass image id as param \n'
    printf 'dclean --> Removes dangling images, stopped containers and unused networks \n'
    printf 'dpurge --> All of "dclean" + unused images and anonymous volumes \n'
    printf 'dqemu  --> QEMU Emulator mode \n'
end
