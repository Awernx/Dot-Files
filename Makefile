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
	SUDO_USER_TARGET ?= $(if $(filter /,$(ROOT_TARGET)),/root,$(ROOT_TARGET)root)
	ROOT_GROUP       := $(shell id -gn root)
endif

# ------------------------------------------------------------------------------
# Per-Package Configurations (Convention-Based)
# ------------------------------------------------------------------------------
COPY_LIST_ENV-Mjolnir 			 := etc/chrony/conf.d/99-stratum-1-priority.conf etc/chrony/sources.d/99-stratum-1.sources etc/sudoers.d/nix-path

USER_IGNORE_REGEX_OS-MacOS       := com\.googlecode\.iterm2\.plist

SUDO_USER_INCLUDE_OS-Common-Unix := .bashrc .config/bash .config/direnv .config/htop .config/vim
SUDO_USER_INCLUDE_OS-Linux       := .config/bash

# ------------------------------------------------------------------------------
# Machine Targets (Convention: PACKAGES_<Machine>, SKIP_SUDO_USER_<Machine>, POST_HOOK_<Machine>)
# ------------------------------------------------------------------------------
MACHINES := macbookpro mjolnir elebook

# macbookpro config
PACKAGES_macbookpro       := OS-Common-Unix OS-MacOS ENV-MacBookPro
SKIP_SUDO_USER_macbookpro := 1
POST_HOOK_macbookpro      := defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

# mjolnir config
PACKAGES_mjolnir          := OS-Common-Unix OS-Linux ENV-Mjolnir

# elebook config
PACKAGES_elebook          := OS-Common-Unix OS-Linux OS-ElementaryOS ENV-Elebook

# PACKAGES_windows-pc := OS-Windows

export IS_WINDOWS USER_TARGET ROOT_TARGET SUDO_USER_TARGET ROOT_GROUP

# ------------------------------------------------------------------------------
# Phony Rules
# ------------------------------------------------------------------------------
.PHONY: $(MACHINES) $(addprefix unstow-,$(MACHINES))

$(MACHINES):
	@$(foreach pkg,$(PACKAGES_$@),SKIP_SUDO_USER="$(SKIP_SUDO_USER_$@)" COPY_LIST="$(COPY_LIST_$(pkg))" USER_IGNORE="$(USER_IGNORE_$(pkg))" USER_IGNORE_REGEX="$(USER_IGNORE_REGEX_$(pkg))" SUDO_USER_INCLUDE="$(SUDO_USER_INCLUDE_$(pkg))" sh ./Makefile.helper deploy "$(pkg)" && ) true
	@if [ -n "$(POST_HOOK_$@)" ]; then \
		echo "=================================================================="; \
		echo "Running post-deploy hooks for $@"; \
		echo "=================================================================="; \
		if [ "$(ROOT_TARGET)" = "/" ] || [ "$(ROOT_TARGET)" = "/c/" ]; then \
			$(or $(POST_HOOK_$@),:); \
		else \
			echo "-> Sandbox mode (ROOT_TARGET=$(ROOT_TARGET)): skipping '$(POST_HOOK_$@)'"; \
		fi; \
	fi

$(addprefix unstow-,$(MACHINES)): unstow-%:
	@$(foreach pkg,$(PACKAGES_$*),SKIP_SUDO_USER="$(SKIP_SUDO_USER_$*)" COPY_LIST="$(COPY_LIST_$(pkg))" USER_IGNORE="$(USER_IGNORE_$(pkg))" USER_IGNORE_REGEX="$(USER_IGNORE_REGEX_$(pkg))" SUDO_USER_INCLUDE="$(SUDO_USER_INCLUDE_$(pkg))" sh ./Makefile.helper remove "$(pkg)" && ) true
