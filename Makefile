SHELL := /bin/sh

# ------------------------------------------------------------------------------
# OS Detection: Windows (MSYS2 / Git Bash) vs. Unix (Linux / macOS)
# ------------------------------------------------------------------------------
ifeq ($(OS),Windows_NT)
	IS_WINDOWS       := 1
	USER_TARGET      ?= $(shell cygpath -u "$(USERPROFILE)" 2>/dev/null || echo "$(HOME)")
	ROOT_TARGET      ?= /c/
	SUDO_USER_TARGET ?=
	ROOT_GROUP       :=
else
	IS_WINDOWS       := 0
	USER_TARGET      ?= $(HOME)
	ROOT_TARGET      ?= /
	SUDO_USER_TARGET ?= $(patsubst %//,%/,$(ROOT_TARGET)/root)
	ROOT_GROUP       := $(shell id -gn root)
endif

# ------------------------------------------------------------------------------
# Per-Package Configurations (Convention-Based)
# ------------------------------------------------------------------------------
COPY_LIST_OS-ElementaryOS        := etc/sudoers.d/nix-path
COPY_LIST_OS-Linux               := etc/chrony

SUDO_USER_INCLUDE_OS-Common-Unix := .bashrc .config/bash .config/direnv .config/fish .config/htop .config/vim .config/yazi
SUDO_USER_INCLUDE_OS-Linux       := .config/bash .config/fish

# ------------------------------------------------------------------------------
# Machine Targets (Convention: PACKAGES_<Machine> and POST_HOOK_<Machine>)
# ------------------------------------------------------------------------------
MACHINES := macbookpro

PACKAGES_macbookpro       := OS-Common-Unix OS-MacOS ENV-MacBookPro
SKIP_SUDO_USER_macbookpro := 1
POST_HOOK_macbookpro      := defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

# PACKAGES_laptop     := OS-Common-Unix OS-Linux OS-ElementaryOS
# POST_HOOK_laptop    := sudo systemctl restart chrony
#
# PACKAGES_server     := OS-Common-Unix OS-Linux
# POST_HOOK_server    := sudo systemctl restart chrony && sudo systemctl daemon-reload
#
# PACKAGES_windows-pc := OS-Windows

export IS_WINDOWS USER_TARGET ROOT_TARGET SUDO_USER_TARGET ROOT_GROUP

# ------------------------------------------------------------------------------
# Phony Rules
# ------------------------------------------------------------------------------
.PHONY: $(MACHINES) $(addprefix unstow-,$(MACHINES))

$(MACHINES):
	@$(foreach pkg,$(PACKAGES_$@),SKIP_SUDO_USER="$(SKIP_SUDO_USER_$@)" COPY_LIST="$(COPY_LIST_$(pkg))" USER_IGNORE="$(USER_IGNORE_$(pkg))" USER_IGNORE_REGEX="$(USER_IGNORE_REGEX_$(pkg))" SUDO_USER_INCLUDE="$(SUDO_USER_INCLUDE_$(pkg))" sh ./Makefile.helper deploy "$(pkg)" && ) true
	@if [ -n "$(POST_HOOK_$@)" ]; then \
		echo "Running post-deploy hooks for $@"; \
		if [ "$(ROOT_TARGET)" = "/" ] || [ "$(ROOT_TARGET)" = "/c/" ]; then \
			$(POST_HOOK_$@); \
		else \
			echo "-> Sandbox mode (ROOT_TARGET=$(ROOT_TARGET)): skipping '$(POST_HOOK_$@)'"; \
		fi; \
	fi

$(addprefix unstow-,$(MACHINES)): unstow-%:
	@$(foreach pkg,$(PACKAGES_$*),SKIP_SUDO_USER="$(SKIP_SUDO_USER_$*)" COPY_LIST="$(COPY_LIST_$(pkg))" USER_IGNORE="$(USER_IGNORE_$(pkg))" USER_IGNORE_REGEX="$(USER_IGNORE_REGEX_$(pkg))" SUDO_USER_INCLUDE="$(SUDO_USER_INCLUDE_$(pkg))" sh ./Makefile.helper remove "$(pkg)" && ) true
