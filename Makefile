# *****************************************************************************
# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# Makefile for Stowing Dot-Files
# *****************************************************************************

STOW_PATH                := $(shell which stow)
DOT_FILES_LOCATION       := $$HOME/Workspace/Dot-Files
ROOT_FOLDER_LOCATION     := /root
BASH_CONFIG_LOCATION     := .config/bash
STOW_COMMAND_PREFIX_HOME := $(STOW_PATH) --dir=$(DOT_FILES_LOCATION) --target=$$HOME
STOW_COMMAND_PREFIX_ROOT := $(STOW_PATH) --dir=$(DOT_FILES_LOCATION) --target=/

.SILENT:

.PHONY: all
all: help

.PHONY: help
help:
	echo "Please specify a target. Available targets are listed below:"
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: stow-mbp
stow-mbp: ## Stow dot-files for Chander's MacBook Pro
	$(STOW_COMMAND_PREFIX_HOME) \
	    --ignore='(\.bashrc)' \
       	--stow OS-Common-Unix OS-MacOS ENV-Chander-MBP

	printf "✅ Chander's MBP Dot-Files stowed successfully\n"

.PHONY: stow-mjolnir
stow-mjolnir: ## Stow dot-files for Mjolnir Linux machine
	# Ignore etc/ when running as USER
	$(STOW_COMMAND_PREFIX_HOME) \
		--ignore='etc' \
		--stow OS-Common-Unix OS-Linux ENV-Chander-Mjolnir

	# Ignore .config/ and .bashrc when running as ROOT
	$(STOW_COMMAND_PREFIX_ROOT) \
		--ignore='(\.config|\.local)' \
		--stow ENV-Chander-Mjolnir

	# Stow .bashrc to /root
	sudo $(STOW_PATH) \
	    --dir=$(DOT_FILES_LOCATION) \
		--target=$(ROOT_FOLDER_LOCATION) \
		--stow OS-Common-Unix

	# # Stow .config/bash to /root
	# sudo mkdir -p $(ROOT_FOLDER_LOCATION)/$(BASH_CONFIG_LOCATION)
	# sudo $(STOW_PATH) \
	#     --dir=$(DOT_FILES_LOCATION)/OS-Common-Unix/.config \
	# 	--target=$(ROOT_FOLDER_LOCATION)/$(BASH_CONFIG_LOCATION) \
	# 	--stow bash

	printf "✅ Mjolnir Dot-Files stowed successfully\n"

.PHONY: stow-elebook
stow-elebook: ## Stow dot-files for elebook (Elementary) laptop
	$(STOW_COMMAND_PREFIX_HOME) \
		--stow OS-Common-Unix OS-Linux OS-ElementaryOS ENV-Chander-Elebook

	printf "✅ Elebook Dot-Files stowed successfully\n"

.PHONY: stow-sath
stow-sath: ## Stow dot-files for Sath (Elementary) machine
	$(STOW_COMMAND_PREFIX_HOME) \
		--stow OS-Common-Unix OS-Linux OS-ElementaryOS ENV-Chander-Sath

	printf "✅ Sath Dot-Files stowed successfully\n"
