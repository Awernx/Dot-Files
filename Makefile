DEFAULT_IGNORE_LIST      = '(\.DS_Store|Makefile$)'
DOT_FILES_LOCATION       = $$HOME/Workspace/Dot-Files
STOW_COMMAND_PREFIX_ROOT = stow --dir=$(DOT_FILES_LOCATION) --target=/
STOW_COMMAND_PREFIX_HOME = stow --dir=$(DOT_FILES_LOCATION) --target=$$HOME/

.PHONY: all stow-chander-mbp 

.SILENT:

all:
	echo "Please specify a target. Available targets:"
	echo "  stow-chander-mbp   Stow dot-files for Chander's MacBook Pro"

stow-chander-mbp: PACKAGES    = OS-Common-Unix OS-MacOS ENV-Chander-MBP
stow-chander-mbp: IGNORE_LIST = '\.DS_Store|com\.googlecode\.iterm2\.plist|Makefile'
stow-chander-mbp:
	printf "\r\033[K🧹 Stowing Chander-MBP"
	$(STOW_COMMAND_PREFIX_HOME) --ignore=$(IGNORE_LIST) --stow $(PACKAGES)
	printf "\r\033[K✅ Chander-MBP Dot-Files stowed successfully\n"
