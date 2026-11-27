# ==============================================================================
# CROSS-PLATFORM DOTFILES & SYSTEM CONFIGURATION DEPLOYMENT FRAMEWORK
# ==============================================================================
#
# USAGE:
#   make <machine>           Deploy all packages & run post_hook for <machine>
#   make unstow-<machine>    Remove/unstow all deployed items for <machine>
#
#   Sandbox testing (override targets without touching system directories):
#   make elebook USER_TARGET=/tmp/test/user ROOT_TARGET=/tmp/test/root
#
# ==============================================================================
# RULE SCHEMA REFERENCE: <Owner>.<Scope>.<Rule>
# ==============================================================================
#
# 1. <Owner> (Precedence from lowest to highest):
#    - <Package>            Applies whenever <Package> is deployed (e.g., OS-Common-Unix)
#    - <Machine>            Applies to all packages on <Machine> (e.g., macbookpro)
#    - <Machine>.<Package>  Applies only to <Package> on <Machine> (e.g., ergo.OS-Common-Unix)
#
# 2. <Scope>:
#    - user                 <Package>/USER -> $(USER_TARGET)
#    - sudo_user            <Package>/USER -> $(SUDO_USER_TARGET) (Unix /root only; skipped on Windows)
#    - root                 <Package>/ROOT -> $(ROOT_TARGET)
#
# 3. <Rule>:
#    - include              Allowlist of paths/globs.
#                           * user & root: If empty, ALL files deploy (default-allow).
#                             If set (especially at <Machine>.<Package>), switches to
#                             allowlist mode so you can cherry-pick individual items.
#                             (<Machine>.<Package>.<Scope>.include REPLACES <Package> include).
#                           * sudo_user: Defaults to default-deny (nothing deploys unless
#                             explicitly listed in include).
#    - exclude              Blocklist of paths/globs. Additive across all layers
#                           (<Package> + <Machine> + <Machine>.<Package>).
#                           ALWAYS wins over include.
#    - map                  Translate source paths to custom destinations using `src:dst`
#                           (e.g., `.config/zed:AppData/Local/Zed`). Works for files & folders.
#    - copy                 Deploy matching paths as standard file copies (Unix & Windows).
#                           Also accepts inline `src:dst` shorthand.
#    - hardlink             (Windows) Deploy matching files as NTFS hard links (file-level).
#                           Recurses into folders so deeper `copy`/`exclude` rules still work.
#                           Also accepts inline `src:dst` shorthand.
#    - junction             (Windows) Deploy matching directories as Directory Junctions
#                           (folder-level). Links the folder directly without recursing.
#                           Also accepts inline `src:dst` shorthand.
#
# 4. PATTERN SYNTAX (for include, exclude, map, and strategy rules):
#    - Exact path / prefix: `.config/zed` matches `.config/zed` and everything under `.config/zed/...`
#    - Glob wildcard:       `*.bak` or `.config/*/cache` (`*` matches within path segments)
#    - Regex prefix:        `re:com\.googlecode\.iterm2\.plist` (matched via regex engine)
#    - Space escaping:      Escape spaces in paths with `\ ` (e.g., `Application\ Support/App`)
#
# ==============================================================================

# ------------------------------------------------------------------------------
# Platform Setup
# ------------------------------------------------------------------------------
ifeq ($(OS),Windows_NT)
	SHELL       := pwsh.exe
	.SHELLFLAGS := -NoProfile -NonInteractive -Command
	HELPER      := pwsh.exe -NoProfile -File ./Makefile.helper.ps1
	USER_TARGET ?= $(USERPROFILE)
	ROOT_TARGET ?= C:/
	IS_WINDOWS  := 1
else
	SHELL            := /bin/sh
	HELPER           := sh ./Makefile.helper
	USER_TARGET      ?= $(HOME)
	SUDO_USER_TARGET ?= $(shell getent passwd root 2>/dev/null | cut -d: -f6 || eval echo ~root)
	ROOT_TARGET      ?= /
	ROOT_GROUP       := $(shell id -gn root)
	IS_WINDOWS       := 0
endif

NORMALIZED_ROOT := $(strip $(ROOT_TARGET))

export IS_WINDOWS USER_TARGET SUDO_USER_TARGET ROOT_TARGET ROOT_GROUP

.SILENT:

# ==============================================================================
# 1. PACKAGES CONFIGURATION
# ==============================================================================

# --- OS-Common-Unix ---
OS-Common-Unix.sudo_user.include := .bashrc .config/bash .config/direnv .config/htop .config/vim

# --- OS-Linux ---
OS-Linux.sudo_user.include       := .config/bash

# --- OS-ElementaryOS ---
OS-ElementaryOS.root.copy        := etc/sudoers.d/nix-path

# --- OS-MacOS ---
OS-MacOS.user.exclude            := re:com\.googlecode\.iterm2\.plist

# --- ENV-Mjolnir ---
ENV-Mjolnir.root.copy            := etc/sudoers.d/nix-path \
                                    etc/chrony/conf.d/99-stratum-1-priority.conf \
                                    etc/chrony/sources.d/99-stratum-1.sources

# --- OS-Windows ---
# Default mode is to copy files on Windows
OS-Windows.user.junction          := AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState \
									 AppData/Roaming/doublecmd \
									 Documents/PowerShell \
									 Documents/CMD

# ==============================================================================
# 2. MACHINES CONFIGURATION
# ==============================================================================
MACHINES := macbookpro mjolnir elebook ergo

macbookpro.packages                    	:= OS-Common-Unix OS-MacOS ENV-MacBookPro
macbookpro.OS-Common-Unix.user.exclude 	:= .bashrc .config/bash
macbookpro.sudo_user.skip         		:= 1
macbookpro.post_hook              		:= defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

mjolnir.packages                  		:= OS-Common-Unix OS-Linux ENV-Mjolnir

elebook.packages                  		:= OS-Common-Unix OS-Linux OS-ElementaryOS ENV-Elebook
elebook.OS-Common-Unix.user.map   		:= .config/zed:.var/app/dev.zed.Zed/config/zed

ergo.packages                     		:= OS-Windows OS-Common-Unix
ergo.sudo_user.skip               		:= 1
ergo.user.hardlink 				  		:= AppData/Roaming/Microsoft/Windows/Start\ Menu/Programs/Startup
ergo.OS-Common-Unix.user.junction 		:= .config/zed:AppData/Roaming/Zed

# ==============================================================================
# 3. RULE RESOLUTION ENGINE (Merges Package + Machine + Machine.Package Layers)
# ==============================================================================
# Resolution helpers:
#   $(call resolve_include,<machine>,<pkg>,<scope>)
#     -> If <machine>.<pkg>.<scope>.include is defined, it replaces <pkg>.<scope>.include.
#     -> Otherwise combines <pkg>.<scope>.include and <machine>.<scope>.include.
#
#   $(call resolve_additive,<machine>,<pkg>,<scope>,<rule>)
#     -> Combines <pkg>.<scope>.<rule>, <machine>.<scope>.<rule>, and <machine>.<pkg>.<scope>.<rule>.

resolve_include = $(strip $(if $(filter undefined,$(origin $(1).$(2).$(3).include)),$($(2).$(3).include) $($(1).$(3).include),$($(1).$(2).$(3).include)))

resolve_additive = $(strip $($(2).$(3).$(4)) $($(1).$(3).$(4)) $($(1).$(2).$(3).$(4)))

# ==============================================================================
# 4. TARGETS & EXECUTION RULES (100% Unified & Cross-Platform)
# ==============================================================================
.PHONY: $(MACHINES) $(addprefix unstow-,$(MACHINES))

$(MACHINES):
	$(foreach pkg,$($@.packages),$(call run_helper,deploy,$(pkg),$@))
	$(call run_post_hook,$@)

$(addprefix unstow-,$(MACHINES)): unstow-%:
	$(foreach pkg,$($*.packages),$(call run_helper,remove,$(pkg),$*))

define run_helper
	$(HELPER) $(1) "$(2)" \
		-SkipSudo "$(strip $($3.sudo_user.skip))" \
		-UserInclude "$(call resolve_include,$3,$2,user)" \
		-UserExclude "$(call resolve_additive,$3,$2,user,exclude)" \
		-UserMap "$(call resolve_additive,$3,$2,user,map)" \
		-UserCopy "$(call resolve_additive,$3,$2,user,copy)" \
		-UserHardlink "$(call resolve_additive,$3,$2,user,hardlink)" \
		-UserJunction "$(call resolve_additive,$3,$2,user,junction)" \
		-SudoInclude "$(call resolve_include,$3,$2,sudo_user)" \
		-SudoExclude "$(call resolve_additive,$3,$2,sudo_user,exclude)" \
		-SudoMap "$(call resolve_additive,$3,$2,sudo_user,map)" \
		-SudoCopy "$(call resolve_additive,$3,$2,sudo_user,copy)" \
		-RootInclude "$(call resolve_include,$3,$2,root)" \
		-RootExclude "$(call resolve_additive,$3,$2,root,exclude)" \
		-RootMap "$(call resolve_additive,$3,$2,root,map)" \
		-RootCopy "$(call resolve_additive,$3,$2,root,copy)" \
		-RootHardlink "$(call resolve_additive,$3,$2,root,hardlink)" \
		-RootJunction "$(call resolve_additive,$3,$2,root,junction)";
endef

define run_post_hook
	$(if $($1.post_hook), \
		echo "Running post-deploy hooks for $1"
		$(if $(filter / C:/ c:/,$(NORMALIZED_ROOT)),$($1.post_hook),echo "-> Sandbox mode: skipping post_hook (ROOT_TARGET='$(NORMALIZED_ROOT)')")
	)
endef
