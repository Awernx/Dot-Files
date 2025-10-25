DOT_FILES_LOCATION  = $$HOME/Workspace/Dot-Files
DESTINATON_LOCATION = $$HOME
IGNORE_LIST         = "\.DS_Store"
STOW_COMMAND        = stow --dir=$(DOT_FILES_LOCATION) --target=$(DESTINATON_LOCATION) --ignore='\.DS_Store' --stow
UNSTOW_COMMAND      = stow --dir=$(DOT_FILES_LOCATION) --target=$(DESTINATON_LOCATION) --delete

CHANDER-MBP-PACKAGES = OS-Common-Unix OS-MacOS ENV-Chander-MBP

.PHONY: all chander-mbp clean-chander-mbp

.SILENT:

all:
	@echo "⚠️ Please specify a target. Available targets:"
	@echo "  chander-mbp        Stow dot-files for Chander's MacBook Pro"
	@echo "  clean-chander-mbp  Unstow dot-files for Chander's MacBook Pro"

chander-mbp:
	printf "\r\033[K🧹 Stowing Chander-MBP"
	$(STOW_COMMAND) $(CHANDER-MBP-PACKAGES)
	printf "\r\033[K✅ Chander-MBP Dot-Files stowed successfully\n"

clean-chander-mbp:
	printf "\r\033[K🧹 Unstowing Chander-MBP"
	$(UNSTOW_COMMAND) $(CHANDER-MBP-PACKAGES)
	printf "\r\033[K✅ Chander-MBP Dot-Files unstowed successfully\n"
