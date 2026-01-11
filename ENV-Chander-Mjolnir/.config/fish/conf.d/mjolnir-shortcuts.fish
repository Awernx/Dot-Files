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
alias tinn-vol  'wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0'
alias tinn-log  'less +F /var/log/tintinnabulator/runtime.log'
alias tinn-stat 'systemctl status tintinnabulator.service'

#------------------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------------------

function tinn-upgrade
    set --local tinn_directory         ~/Workspace/Tintinnabulator
    set --local tinn_install_directory /tmp/tinn
    set --local current_directory      (pwd)
    set --local last_run_id_file       $tinn_install_directory/.last_run_id
    set --local last_run_id            ''
    set --local exec_command           env DIRENV_LOG_FORMAT="" direnv exec $tinn_directory

    if test -f "$last_run_id_file"
        set last_run_id (/usr/bin/cat "$last_run_id_file")
    else
       	printf "\r\033[KCould not find a record of previous download"
        mkdir --parents $tinn_install_directory
    end

    set --local recent_run_id (
        begin
            cd $tinn_directory # gh needs to run within the specific repo
            $exec_command gh run list --limit 1 --json databaseId --jq '.[0].databaseId'
            cd $current_directory
        end
    )

    if test "$recent_run_id" = "$last_run_id"
       	printf "\r\033[K✅ Tintinnabulator is already the newest version\n"
        return 0
    end

   	printf "\r\033[KDownloading the latest version from GitHub\r"

    set --local download_output (
        begin
            cd $tinn_directory # gh needs to run within the specific repo
            $exec_command gh run download --dir /tmp/tinn $recent_run_id --pattern "*.deb" 2>&1
        end
    )

    set --local status_code $status

    cd $current_directory
    if test $status_code -ne 0
        if string match -q "*no valid artifacts found to download*" "$download_output"
           	printf "\r\033[K⚠️  Error: Debian package for GitHub run [%s] has expired or does not exist\n" $recent_run_id
            return 1
        else
           	printf "\r\033[K⚠️  Debian package download failed - %s \n" $download_output
            return 1
        end
    end

   	printf "\r\033[KInstalling ...\r"
    set --local deb_file (find $tinn_install_directory -type f -name "*.deb") # because gh download creates a sub-directory
    sudo apt-get install -qq --yes $deb_file > /dev/null

    find $tinn_install_directory  -mindepth 1 -maxdepth 1  -type d -exec rm -rf {} \; # delete all directories inside
    echo $recent_run_id > $last_run_id_file
   	printf "\r\033[K✅ Tintinnabulator has been upgraded to the newest version\n"
end

# List all tinn_ shortcuts
function mj-help
    printf '\nMjolnir shorcuts\n'
    printf '----------------------------------------------------------------\n'
    printf 'vol          --> Gets current volume level \n'
    printf 'wol          --> Prints Wake-On-Lan status \n'
    printf 'sleep        --> Suspends the system \n\n'

    printf 'tinn-vol     --> Sets system volume to max level  \n'
    printf 'tinn-log     --> Tails Tinn runtime log \n'
    printf 'tinn-stat    --> Prints system.d status for Tinn service \n'
    printf 'tinn-upgrade --> Upgrades Tinn to the latest version from GitHub \n\n'

    printf 'mega-synch   --> Starts MEGASync & waits until synced \n'
    printf 'backup-cloud --> Back up GDrive & MEGA artifacts to Svalbard \n'
end

# Performs 2 functions
# 1) Starts MEGASync if it's not already running
# 2) Waits until the sync has completed
function mega-synch
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

# Back up Google Drive & MEGA artifacts to Svalbard
function backup-cloud
    set --local svalbard_docs_folder /mnt/svalbard/Documents
    set --local mega_folder          (realpath ~/'Cloud/Mega')
    set --local gdrive_folder        (realpath ~/'Cloud/GoogleDrive')
    set --local rsync_command        rsync --archive --human-readable --delete

    # --------- MEGA Backup Section ------------------------------------
    # Ensure MEGA is synced
    mega-synch

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
