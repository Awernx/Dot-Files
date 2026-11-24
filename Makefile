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

export IS_WINDOWS USER_TARGET ROOT_TARGET SUDO_USER_TARGET ROOT_GROUP

# ==============================================================================
# PACKAGES Config
# ==============================================================================

# --- OS-Common-Unix ---
OS-Common-Unix.sudo_user.include := .bashrc .config/bash .config/direnv .config/htop .config/vim

OS-Linux.sudo_user.include       := .config/bash

OS-ElementaryOS.root.copy        := etc/sudoers.d/nix-path

OS-MacOS.user.ignore_regex       := com\.googlecode\.iterm2\.plist

ENV-Mjolnir.root.copy            := etc/sudoers.d/nix-path \
                                    etc/chrony/conf.d/99-stratum-1-priority.conf \
                                    etc/chrony/sources.d/99-stratum-1.sources

# ==============================================================================
# 2. MACHINES (Colocated per machine: <Machine>.<property>)
# ==============================================================================
MACHINES := macbookpro mjolnir elebook

macbookpro.packages       := OS-Common-Unix OS-MacOS ENV-MacBookPro
macbookpro.sudo_user.skip := 1
macbookpro.post_hook      := defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

mjolnir.packages          := OS-Common-Unix OS-Linux ENV-Mjolnir

elebook.packages          := OS-Common-Unix OS-Linux OS-ElementaryOS ENV-Elebook

# --- windows-pc ---
# windows-pc.packages     := OS-Windows

# ==============================================================================
# 3. TARGETS & EXECUTION RULES
# ==============================================================================
.PHONY: $(MACHINES) $(addprefix unstow-,$(MACHINES))

$(MACHINES):
	@$(foreach pkg,$($@.packages), \
		SKIP_SUDO_USER="$($@.sudo_user.skip)" \
		COPY_LIST="$($(pkg).root.copy)" \
		USER_IGNORE="$($(pkg).user.ignore)" \
		USER_IGNORE_REGEX="$($(pkg).user.ignore_regex)" \
		SUDO_USER_INCLUDE="$($(pkg).sudo_user.include)" \
		sh ./Makefile.helper deploy "$(pkg)" && ) true
	@if [ -n "$($@.post_hook)" ]; then \
		echo "Running post-deploy hooks for $@"; \
		if [ "$(ROOT_TARGET)" = "/" ] || [ "$(ROOT_TARGET)" = "/c/" ]; then \
			$(or $($@.post_hook),:); \
		else \
			echo "-> Sandbox mode (ROOT_TARGET=$(ROOT_TARGET)): skipping '$($@.post_hook)'"; \
		fi; \
	fi

$(addprefix unstow-,$(MACHINES)): unstow-%:
	@$(foreach pkg,$($*.packages), \
		SKIP_SUDO_USER="$($*.sudo_user.skip)" \
		COPY_LIST="$($(pkg).root.copy)" \
		USER_IGNORE="$($(pkg).user.ignore)" \
		USER_IGNORE_REGEX="$($(pkg).user.ignore_regex)" \
		SUDO_USER_INCLUDE="$($(pkg).sudo_user.include)" \
		sh ./Makefile.helper remove "$(pkg)" && ) true
