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
    set --local exec_command           env DIRENV_LOG_FORMAT="" direnv exec $tinn_directory
    set --local current_version        (dpkg-query -W -f='${Version}\n' tintinnabulator)

    rm -rf $tinn_install_directory # just in case previous run did not exit cleanly
    mkdir --parents $tinn_install_directory

   	printf "\r\033[KDownloading latest Tintinnabulator release from GitHub ...\r"
    set --local download_output (
        begin
            cd $tinn_directory # gh needs to run within the specific repo
            $exec_command gh release download --pattern "*.deb" --dir $tinn_install_directory 2>&1
        end
    )

    set --local status_code $status

    cd $current_directory
    if test $status_code -ne 0
       	printf "\r\033[K⚠️  Debian package download failed - %s \n" $download_output
        rm -rf $tinn_install_directory
        return 1
    end

    set --local deb_file    (find $tinn_install_directory -type f -name "*.deb")
    set --local new_version (echo $deb_file | sed -E 's/^[^_]+_([^_]+)_.+\.deb$/\1/')

    if test "$current_version" = "$new_version"
       	printf "\r\033[K✅ Tintinnabulator is already the newest version\n"
        rm -rf $tinn_install_directory
        return 0
    end

   	printf "\r\033[KInstalling new version of Tintinnabulator...\r"
    sudo apt-get install -qq --yes $deb_file > /dev/null

    rm -rf $tinn_install_directory
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
