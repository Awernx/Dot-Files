#!/usr/bin/env fish

# Stop loading this script for non-interactive shells
if not status is-interactive
    exit 0
end

#------------------------------------------------------------------------------------------
# Global variables
#------------------------------------------------------------------------------------------
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
    # Turn off 'direnv' logs during this upgrade process
    set --function --export DIRENV_LOG_FORMAT ''

    set --local tinn_directory         ~/Workspace/Tintinnabulator
    set --local tinn_install_directory /tmp/tinn
    set --local current_directory      (pwd)
    set --local last_run_id_file       $tinn_install_directory/.last_run_id
    set --local last_run_id            ''

    if test -f "$last_run_id_file"
        set last_run_id (cat "$last_run_id_file")
    else
        mkdir --parents $tinn_install_directory
    end

    cd $tinn_directory # gh needs to run within the specific repo
    set --local recent_run_id (direnv exec $tinn_directory gh run list --limit 1 --json databaseId --jq '.[0].databaseId')

    if test "$recent_run_id" = "$last_run_id"
        echo "✅ Tintinnabulator is already on the latest version"
        cd $current_directory # Return to the previous directory
        return 0
    end

    echo "New version of Tintinnabulator available; Downloading..."
    direnv exec $tinn_directory gh run download --dir $tinn_install_directory $recent_run_id --pattern "*.deb"
    cd $current_directory # Return to the previous directory

    set --local deb_file (find $tinn_install_directory -type f -name "*.deb") # because gh download creates a sub-directory
    sudo apt install -qq --yes $deb_file

    find $tinn_install_directory  -mindepth 1 -maxdepth 1  -type d -exec rm -rf {} \; # delete all directories inside
    echo $recent_run_id > $last_run_id_file
end

# Performs 2 functions
# 1) Starts MEGASync if it's not already running
# 2) Waits until the sync has completed
function wait-for-mega-sync
    if not pgrep --exact mega-cmd-server > /dev/null
        echo -ne '⚠️ MEGASync is not running; Starting it now '
        /usr/bin/mega-sync > /dev/null 2>&1
    end

    while true
        set current_status (mega-sync --output-cols=STATUS 2>/dev/null | grep -E 'Synced|Pending|Syncing|Processing|NONE' | tail -n 1 | xargs)
        if test "$current_status" = "Synced"
            echo -e "\r\033[K✅ MEGA is synced"
            break
        end

        printf "\rWaiting for MEGA to complete sync... Current Status: %s" $current_status
        sleep 1 # Wait for a second
    end
end

# Back up Google Drive & MEGA artifacts in to Svalbard
function backup-cloud
    set --local svalbard_docs_folder /mnt/svalbard/Documents
    set --local mega_folder          (realpath ~/'Cloud/Mega')
    set --local gdrive_folder        (realpath ~/'Cloud/GoogleDrive')
    set --local rsync_command        rsync --archive --human-readable --delete

    # --------- MEGA Backup Section ------------------------------------
    # Ensure MEGA is synced
    wait-for-mega-sync

    echo -ne 'Backing up MEGASync to Svalbard' \r
    $rsync_command $mega_folder/KitchenSink/                $svalbard_docs_folder/KitchenSink
    $rsync_command $mega_folder/Personal_Backups/           $svalbard_docs_folder/Personal_Backups/
    $rsync_command $mega_folder/Sensitive_Family_Documents/ $svalbard_docs_folder/Sensitive_Family_Documents/

    echo '✅ MEGASync backed up successfully           '

    # --------- Google Drive Backup Section ----------------------------
    echo -ne 'Fetching contents from Google Drive' \r
    rclone sync --include 'Family*/**' google-drive: $gdrive_folder

    echo -ne 'Backing up Google Drive to Svalbard' \r
    $rsync_command $gdrive_folder/'Family Documents'/ $svalbard_docs_folder/Google_Drive_Documents/

    echo '✅ Google Drive backed up successfully       '
end
