# ------------------------------------------------------------------------------
# Platform Setup (Only difference between Windows and Unix is here)
# ------------------------------------------------------------------------------
ifeq ($(OS),Windows_NT)
	SHELL       := pwsh.exe
	.SHELLFLAGS := -NoProfile -NonInteractive -Command
	HELPER      := pwsh.exe -NoProfile -File ./Makefile.helper.ps1
	USER_TARGET ?= $(USERPROFILE)
	ROOT_TARGET ?= C:\
	IS_WINDOWS  := 1
else
	SHELL       := /bin/sh
	HELPER      := sh ./Makefile.helper
	USER_TARGET ?= $(HOME)
	ROOT_TARGET ?= /
	ROOT_GROUP  := $(shell id -gn root)
	IS_WINDOWS  := 0
endif

export IS_WINDOWS USER_TARGET ROOT_TARGET ROOT_GROUP

# ==============================================================================
# 1. PACKAGES Config
# ==============================================================================
OS-Common-Unix.sudo_user.include := .bashrc .config/bash .config/direnv .config/htop .config/vim
OS-Linux.sudo_user.include       := .config/bash
OS-ElementaryOS.root.copy        := etc/sudoers.d/nix-path
OS-MacOS.user.ignore_regex       := com\.googlecode\.iterm2\.plist
ENV-Mjolnir.root.copy            := etc/sudoers.d/nix-path \
                                    etc/chrony/conf.d/99-stratum-1-priority.conf \
                                    etc/chrony/sources.d/99-stratum-1.sources

# ==============================================================================
# 2. MACHINES
# ==============================================================================
MACHINES := macbookpro mjolnir elebook ergo

macbookpro.packages       := OS-Common-Unix OS-MacOS ENV-MacBookPro
macbookpro.sudo_user.skip := 1
macbookpro.post_hook      := defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

mjolnir.packages          := OS-Common-Unix OS-Linux ENV-Mjolnir

elebook.packages          := OS-Common-Unix OS-Linux OS-ElementaryOS ENV-Elebook

ergo.packages       	  := OS-Windows
ergo.sudo_user.skip 	  := 1

# ==============================================================================
# 3. TARGETS & EXECUTION RULES (100% Unified)
# ==============================================================================
.PHONY: $(MACHINES) $(addprefix unstow-,$(MACHINES))

$(MACHINES):
	@$(foreach pkg,$($@.packages),$(call run_helper,deploy,$(pkg))$(newline))
	@$(call run_post_hook,$@)

$(addprefix unstow-,$(MACHINES)): unstow-%:
	@$(foreach pkg,$($*.packages),$(call run_helper,remove,$(pkg))$(newline))

define newline


endef

# Helper macro: exports per-package vars and invokes $(HELPER)
define run_helper
	$(eval export SKIP_SUDO_USER=$($@.sudo_user.skip))
	$(eval export COPY_LIST=$($(2).root.copy))
	$(eval export USER_IGNORE=$($(2).user.ignore))
	$(eval export USER_IGNORE_REGEX=$($(2).user.ignore_regex))
	$(eval export SUDO_USER_INCLUDE=$($(2).sudo_user.include))
	@$(HELPER) $(1) "$(2)"
endef

define run_post_hook
	$(if $($1.post_hook), \
		@echo "Running post-deploy hooks for $1" && \
		$(if $(filter / C:\ C:/,$(ROOT_TARGET)),$($1.post_hook),@echo "-> Sandbox mode: skipping post_hook"))
endef
