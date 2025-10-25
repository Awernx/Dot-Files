#!/usr/bin/env fish

# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# -------------------------------------
# Bootstrapper script specific to ergo

# ElementaryOS files shortcut
alias open "io.elementary.files"

# NeoVim is installed as flatpak
alias nvim 'flatpak run io.neovim.nvim'

# Update bootstrapper code with the latest from Git repositories
set --export --universal GIT_REPOS ~/Workspace/Tintinnabulator ~/Workspace/machine-settings ~/Workspace/Linux-DotFiles ~/Workspace/ResourceFiles

set --export --global EDITOR (which vi)
set --export --global BASE_OS (awk -F '=' '$1 == "UBUNTU_VERSION" {gsub(/"/, ""); BASE=$2} END {printf "Ubuntu %s", BASE}' /etc/os-release)

function bootstrap
    set -l home_folder ~/Workspace/machine-settings/ergo

    echo 'Setting up elementaryos (g)settings'
    # Clock settings
    gsettings set io.elementary.desktop.wingpanel.datetime clock-show-weekday true
    gsettings set io.elementary.desktop.wingpanel.datetime clock-show-seconds true
    gsettings set io.elementary.desktop.wingpanel.datetime clock-format '12h'

    # Special keys tray settings
    gsettings set io.elementary.wingpanel.keyboard numlock true
    gsettings set io.elementary.wingpanel.keyboard capslock true

    gsettings set io.elementary.files.preferences show-hiddenfiles true
    gsettings set io.elementary.files.preferences singleclick-select true

    # Terminal settings
    gsettings set io.elementary.terminal.settings cursor-shape 'I-Beam'
    # Gruvbox color theme
    gsettings set io.elementary.terminal.settings background 'rgba(40,40,40,0.936396)'
    gsettings set io.elementary.terminal.settings foreground 'rgb(235,219,178)'
    gsettings set io.elementary.terminal.settings palette 'rgb(40,40,40):rgb(204,36,29):rgb(152,151,26):rgb(215,153,33):rgb(69,133,136):rgb(177,98,134):rgb(104,157,106):rgb(168,153,132):rgb(146,131,116):rgb(251,73,52):rgb(184,187,38):rgb(250,189,47):rgb(131,165,152):rgb(211,134,155):rgb(142,192,124):rgb(235,219,178)'

    echo 
    echo 'Setting up AutoKey'
    mkdir -p ~/.config/autokey
    ln -sfn $home_folder/.config/autokey/data/ ~/.config/autokey/data

    echo 
    echo 'Setting up USB-triggered wakeup'
    sudo ln -sf $home_folder/lib/systemd/system-sleep/usb-trigger-wakeup.bash /lib/systemd/system-sleep/

    echo 
    echo 'Setting up Logitech MX Keys'
    sudo ln -sf $home_folder/etc/udev/hwdb.d/logitech-mx-keys.hwdb /etc/udev/hwdb.d/
    sudo systemd-hwdb update
    sudo udevadm trigger /dev/input/event*
    echo 'Note: Restart computer to complete MX Keys set'

    # echo 
    # echo 'Mounting shared drive BK 1 from MissionControl'
    # sudo mkdir -p /mnt/bk1
    # grep -q 'missioncontrol.blisshighway' /etc/fstab || 
    #     printf '\n# BK 1 on MissionControl\n//missioncontrol.blisshighway/bk1  /mnt/bk1  cifs  rw,guest,x-systemd.automount,uid='(id -u)',gid='(id -g)'  0  0\n' \
    #   | sudo tee --append /etc/fstab
end

function bk_cloud
  set -l bk1_root_folder /media/chander/BK1
  set -l bk1_documents_folder $bk1_root_folder/Documents/
  set -l gdrive_local_folder (realpath ~/'Cloud Drives/GoogleDrive/')
  set -l mega_local_folder (realpath ~/'Cloud Drives/MEGA/')

  echo -ne 'Fetching contents from GDrive' \\r
  rclone sync --include 'Family*/**' --include 'Resume/**' --include 'Stationary/**'  Chander_Google_Drive: $gdrive_local_folder

  echo -ne 'Backing up GDrive contents to BK1' \\r
  rsync -ah $gdrive_local_folder/'Resume' $bk1_documents_folder/'Personal Backups/Chander/GDrive/' --delete
  rsync -ah $gdrive_local_folder/'Stationary' $bk1_documents_folder/'Personal Backups/Chander/GDrive/' --delete
  rsync -ah $gdrive_local_folder/'Family Documents' $bk1_documents_folder/'Miscellaneous/GDrive/' --delete
  
  echo -ne 'Backing up MEGA contents to BK1  ' \\r
  rsync -ah $mega_local_folder/'Personal Backups' $bk1_documents_folder/ --delete --exclude 'CPA Study Material.zip'
  rsync -ah $mega_local_folder/'Sensitive Family Documents' $bk1_documents_folder/ --delete
  rsync -ah $mega_local_folder/'KitchenSink' $bk1_documents_folder/'Miscellaneous/' --delete --exclude 'Short-term'
  
  echo 'Cloud content backup to BK1 completed'
end