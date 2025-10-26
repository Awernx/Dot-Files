# *****************************************************************************
# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# Makefile for Stowing Dot-Files
# *****************************************************************************

DEFAULT_IGNORE_LIST      = \.DS_Store|Makefile
DOT_FILES_LOCATION       = $$HOME/Workspace/Dot-Files
STOW_COMMAND_PREFIX_ROOT = stow --dir=$(DOT_FILES_LOCATION) --target=/
STOW_COMMAND_PREFIX_HOME = stow --dir=$(DOT_FILES_LOCATION) --target=$$HOME

.PHONY: all stow-mbp stow-mjolnir

.SILENT:

all:
	echo "Please specify a target. Available targets:"
	echo "  stow-mbp   		Stow dot-files for Chander's MacBook Pro"
	echo "  stow-mjolnir    Stow dot-files for Mjolnir Linux machine"

# *****************************************************************************
# Chander's MBP Stow Target
# *****************************************************************************
stow-mbp: PACKAGES         = OS-Common-Unix OS-MacOS ENV-Chander-MBP
stow-mbp: IGNORE_ADDITIONS = com\.googlecode\.iterm2\.plist
stow-mbp:
	printf "\r\033[K🧹 Stowing Chander's MBP Dot-Files"
	$(STOW_COMMAND_PREFIX_HOME) --ignore='($(DEFAULT_IGNORE_LIST)|$(IGNORE_ADDITIONS))' --stow $(PACKAGES)
	printf "\r\033[K✅ Chander's MBP Dot-Files stowed successfully\n"

# *****************************************************************************
# Mjolnir Stow Target
# *****************************************************************************
stow-mjolnir: PACKAGES_STG_1   = OS-Common-Unix OS-Linux ENV-Chander-Mjolnir
stow-mjolnir: PACKAGES_STG_2   = ENV-Chander-Mjolnir
stow-mjolnir: IGNORE_ADD_STG_1 = readme\.md|etc
stow-mjolnir: IGNORE_ADD_STG_2 = readme\.md|\.config|fstab\.bak
stow-mjolnir:
	printf "\r\033[K🧹 Stowing Mjolnir Dot-Files - Stage 1"
	$(STOW_COMMAND_PREFIX_HOME) --ignore='($(DEFAULT_IGNORE_LIST)|$(IGNORE_ADD_STG_1))' --stow $(PACKAGES_STG_1)

	printf "\r\033[K🧹 Stowing Mjolnir Dot-Files - Stage 2"
	$(STOW_COMMAND_PREFIX_ROOT) --ignore='($(DEFAULT_IGNORE_LIST)|$(IGNORE_ADD_STG_2))' --stow $(PACKAGES_STG_2)

	printf "\r\033[K✅ Mjolnir Dot-Files stowed successfully\n"
