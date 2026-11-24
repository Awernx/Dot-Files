#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------------------------------
# FISH shell shortcuts for docker commands

# ======================================================================
# NOTE: All commands below need root access (sudo)
#       To avoid that, add current user to Docker group
#       Ref: https://docs.docker.com/engine/install/linux-postinstall/
# ======================================================================

# Don't load this script for non-interactive shells
status is-interactive; or exit 0

# QEMU is a type-2 hypervisor that allows you to run virtual machines on your host system.
# It can emulate a wide range of architectures, including x86 and ARM.
# The qemu-system-aarch64 package provides an AArch64 (ARM64) system emulator,
# which can be used to emulate an entire system, including the CPU and various peripheral devices.
# To build code on Raspberry Pi, QEMU can be used to simulate an AArch64 system on an x86 machine
abbr dqemu  'docker run --privileged --rm tonistiigi/binfmt --install all'
abbr dclean 'docker system prune --force'
abbr dpurge 'docker system prune --all --volumes --force'
abbr drm    'docker image rm --force' # Remove a specific image -> Pass image id as param
# Tab-completion for the 'drm' abbr/command
complete -c drm -f -a "(docker images --format '{{.Repository}}:{{.Tag}}\t{{.Size}} ({{.ID}})' 2>/dev/null | string replace -r '^<none>:<none>\t' '' | string match -v '<none>*')"


# List all images and containers
function dl --description "Overview of Docker images, containers, and networks"
    if not type -q docker; or not docker info >/dev/null 2>&1
        set_color -o brred; echo "Docker daemon is not running."; set_color normal
        return 1
    end

    set -l rule (string repeat -n 74 '─')

    set_color -o bryellow; printf '\nIMAGES\n%s\n' $rule; set_color normal
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedSince}}"

    set_color -o brcyan; printf '\nCONTAINERS\n%s\n' $rule; set_color normal
    docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

    set_color -o brgreen; printf '\nNETWORKS\n%s\n' $rule; set_color normal
    docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"
    echo
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
