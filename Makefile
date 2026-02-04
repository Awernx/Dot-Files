# *****************************************************************************
# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# Makefile for Stowing Dot-Files
# *****************************************************************************

STOW_PATH                := $(shell which stow)
DOT_FILES_LOCATION       := $$HOME/Workspace/Dot-Files
STOW_COMMAND_PREFIX_ROOT := $(STOW_PATH) --dir=$(DOT_FILES_LOCATION) --target=/
STOW_COMMAND_PREFIX_HOME := $(STOW_PATH) --dir=$(DOT_FILES_LOCATION) --target=$$HOME

.SILENT:

.PHONY: all
all: help

.PHONY: help
help:
	echo "Please specify a target. Available targets are listed below:"
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: stow-mbp
stow-mbp: ## Stow dot-files for Chander's MacBook Pro
	$(STOW_COMMAND_PREFIX_HOME) --stow OS-Common-Unix OS-MacOS ENV-Chander-MBP
	printf "✅ Chander's MBP Dot-Files stowed successfully\n"

.PHONY: stow-mjolnir
stow-mjolnir: ## Stow dot-files for Mjolnir Linux machine
	$(STOW_COMMAND_PREFIX_HOME) \
		--ignore='etc' \
		--stow OS-Common-Unix OS-Linux ENV-Chander-Mjolnir

	sudo $(STOW_COMMAND_PREFIX_ROOT) \
		--ignore='(\.config|\.bashrc)' \
		--stow ENV-Chander-Mjolnir

	printf "✅ Mjolnir Dot-Files stowed successfully\n"

.PHONY: stow-sath
stow-sath: ## Stow dot-files for Sath (Elementary) machine
	$(STOW_COMMAND_PREFIX_HOME) \
		--stow OS-Common-Unix OS-Linux OS-ElementaryOS ENV-Chander-Sath

	printf "✅ Sath Dot-Files stowed successfully\n"
