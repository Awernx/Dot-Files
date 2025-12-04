#!/usr/bin/env fish

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end

#------------------------------------------------------------------------------------------
# Global variables
#------------------------------------------------------------------------------------------
set --export --global    HOST_BANNER "\

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
abbr vol   'wpctl get-volume @DEFAULT_AUDIO_SINK@'
abbr wol   'sudo ethtool eno1 | grep Wake' # Understand output https://askubuntu.com/questions/1267124/wake-on-lan-issues
abbr sleep 'systemctl suspend'

#------------------------------------------------------------------------------------------
# Aliases
#------------------------------------------------------------------------------------------
alias tinn_vol  'wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0'
alias tinn_log  'less +F /var/log/tintinnabulator/runtime.log'
alias tinn_stat 'systemctl status tintinnabulator.service'

#------------------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------------------

function tinn_upgrade
    set -l  tinn_directory         ~/Workspace/Tintinnabulator
    set -l  current_directory      (pwd)
    set -l  tinn_install_directory /tmp/tinn
    set -l  last_run_id_file       $tinn_install_directory/.last_run_id
    set -l  last_run_id            ''
    set -fx DIRENV_LOG_FORMAT      ''

    cd $tinn_directory # gh needs to run within the specific repo
    set -l recent_run_id          (direnv exec $tinn_directory gh run list --limit 1 --json databaseId --jq '.[0].databaseId')

    if test -f "$last_run_id_file"
        set last_run_id (cat "$last_run_id_file")
    else
        mkdir -p $tinn_install_directory
    end

    if test "$recent_run_id" = "$last_run_id"
        echo "Tintinnabulator is already on the latest version"
        cd $current_directory # Return to the previous directory
        return 0
    end

    echo "New version available; Downloading..."
    direnv exec $tinn_directory gh run download --dir $tinn_install_directory $recent_run_id --pattern "*.deb"

    cd $current_directory # Return to the previous directory

    set -l deb_file (find $tinn_install_directory -type f -name "*.deb") # because gh download creates a sub-directory
    sudo apt install -qq -y $deb_file

    find $tinn_install_directory  -mindepth 1 -maxdepth 1  -type d -exec rm -rf {} \; # delete all directories inside
    echo $recent_run_id > $last_run_id_file
end

# Back up Google Drive & MEGA artifacts in to Svalbard
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
