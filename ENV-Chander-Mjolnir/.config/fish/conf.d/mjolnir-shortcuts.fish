#!/usr/bin/env fish

# IMPORTANT: Do not load this script for non-interactive shells
if not status is-interactive
    exit 0
end

#------------------------------------------------------------------------------------------
# Global variables
#------------------------------------------------------------------------------------------
set --export --universal GIT_REPOS ~/Workspace/Machine-Settings ~/Workspace/Linux-DotFiles
set --global FILES_HOME ~/Workspace/Machine-Settings/mjolnir
set --export --global HOST_BANNER "\

  ▄▄▄▄███▄▄▄▄        ▄█  ▄██████▄   ▄█       ███▄▄▄▄    ▄█     ▄████████
▄██▀▀▀███▀▀▀██▄     ███ ███    ███ ███       ███▀▀▀██▄ ███    ███    ███
███   ███   ███     ███ ███    ███ ███       ███   ███ ███▌   ███    ███
███   ███   ███     ███ ███    ███ ███       ███   ███ ███▌  ▄███▄▄▄▄██▀
███   ███   ███     ███ ███    ███ ███       ███   ███ ███▌ ▀▀███▀▀▀▀▀  
███   ███   ███     ███ ███    ███ ███       ███   ███ ███  ▀███████████
███   ███   ███     ███ ███    ███ ███▌    ▄ ███   ███ ███    ███    ███
 ▀█   ███   █▀  █▄ ▄███  ▀██████▀  █████▄▄██  ▀█   █▀  █▀     ███    ███
                ▀▀▀▀▀▀             ▀                          ███    ███    
"

#------------------------------------------------------------------------------------------
# Abbreviations
#------------------------------------------------------------------------------------------
abbr sleep 'systemctl suspend'

# Check if Wake-On-Lan is enabled
# Refer here to understand output --> https://askubuntu.com/questions/1267124/wake-on-lan-issues
abbr wol 'sudo ethtool eno1 | grep Wake'

#------------------------------------------------------------------------------------------
# Function to back up Google Drive & MEGA artifacts in to Svalbard
#------------------------------------------------------------------------------------------
function bk_cloud

    # Start mega-sync is its not running
    if not pgrep -x mega-cmd-server > /dev/null
        echo -ne 'Starting MEGASync ...' \r
        /usr/bin/mega-sync
        sleep 2
    end

    echo '✅ MEGASync is running                       '

        set -l svalbard_root_folder /mnt/svalbard
    set -l svalbard_documents_folder $svalbard_root_folder/Documents

    # --------- Google Drive Backup Section ----------------------------
    set -l gdrive_folder (realpath ~/'Cloud/GoogleDrive')

    echo -ne 'Fetching contents from Google Drive' \r
    rclone sync --include 'Family*/**' google-drive: $gdrive_folder

    echo -ne 'Backing up Google Drive to Svalbard' \r
    rsync -ah --delete $gdrive_folder/'Family Documents'/ $svalbard_documents_folder/Google_Drive_Documents/    

    echo '✅ Google Drive backed up successfully       '

    # --------- MEGA Backup Section ------------------------------------
    set -l mega_folder (realpath ~/'Cloud/Mega')

    echo -ne 'Backing up MEGASync to Svalbard' \r
    rsync -ah --delete $mega_folder/Sensitive_Family_Documents/ $svalbard_documents_folder/Sensitive_Family_Documents/
    rsync -ah --delete $mega_folder/Personal_Backups/ $svalbard_documents_folder/Personal_Backups/
    rsync -ah --delete $mega_folder/KitchenSink/ $svalbard_documents_folder/KitchenSink

    echo '✅ MEGASync backed up successfully           '
end
