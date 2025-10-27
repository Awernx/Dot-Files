# *****************************************************************************
# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# Makefile for Stowing Dot-Files
# *****************************************************************************

STOW_PATH                := $(shell which stow)
DOT_FILES_LOCATION       := $$HOME/Workspace/Dot-Files
STOW_COMMAND_PREFIX_ROOT := $(STOW_PATH) --dir=$(DOT_FILES_LOCATION) --target=/
STOW_COMMAND_PREFIX_HOME := $(STOW_PATH) --dir=$(DOT_FILES_LOCATION) --target=$$HOME

.PHONY: all stow-mbp stow-mjolnir

.SILENT:

all:
	echo "Please specify a target. Available targets:"
	echo "  stow-mbp        Stow dot-files for Chander's MacBook Pro"
	echo "  stow-mjolnir    Stow dot-files for Mjolnir Linux machine"

# *****************************************************************************
# Chander's MBP Stow Target
# *****************************************************************************
stow-mbp:
	$(STOW_COMMAND_PREFIX_HOME) --stow OS-Common-Unix OS-MacOS ENV-Chander-MBP
	printf "✅ Chander's MBP Dot-Files stowed successfully\n"

# *****************************************************************************
# Mjolnir Stow Target
# *****************************************************************************
stow-mjolnir:
	$(STOW_COMMAND_PREFIX_HOME) \
		--ignore='etc' \
		--stow OS-Common-Unix OS-Linux ENV-Chander-Mjolnir

	sudo $(STOW_COMMAND_PREFIX_ROOT) \
		--ignore='(\.config|\.bashrc)' \
		--stow ENV-Chander-Mjolnir

	printf "✅ Mjolnir Dot-Files stowed successfully\n"
