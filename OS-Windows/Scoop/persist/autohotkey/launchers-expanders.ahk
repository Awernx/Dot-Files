; 🅲 🅷 🅰 🅽 🅳 🅴 🆁
; ------------------------------------------------------------------------------------
; AutoHotKey customizations
;
; Add link to [AppData]\Roaming\Microsoft\Windows\Start Menu\Programs\Startup

; Set NumLock 'ON'
SetNumlockState "AlwaysOn"

; ========================================================
;                   Text Expansions
;           All shortcuts to be prefixed with ':'
; ========================================================
; Indian Rupee Symbol  --> :inr
:::inr::{U+20B9}

:::pls::Please let me know if you have any questions or need additional information.
:::thx::Thanks,`nChander

; ========================================================
;           Application Launchers
; ========================================================

ScoopAppsDirectory := EnvGet("LocalAppData") . "\Programs\scoop\apps"

; Ctrl + PrintScreen ---> Flameshot
^PrintScreen::Run ScoopAppsDirectory . "\flameshot\current\bin\flameshot.exe"

; Ctrl + Alt + Win + T ---> Terminal
^!#T:: Run "wt.exe"

; Ctrl + Alt + Win + B ---> Browser
^!#B::Run A_ProgramFiles . "\Mozilla Firefox\firefox.exe"

; Ctrl + Alt + Win + V ---> Zed Editor
^!#V:: ActivateOrLaunch("Zed", ScoopAppsDirectory . "\zed\current\Zed.exe")

; Ctrl + Alt + Win + Y ---> KeePass
^!#Y:: ActivateOrLaunch("Keepass", "KeePass.exe")

ActivateOrLaunch(windowName, executableLocation)
{
    SetTitleMatchMode 2
    if WinExist(windowName)
        WinActivate       
    else
        Run executableLocation
}

; ========================================================
;    Folder Shortcuts --> Ctrl + Shift + ....
; ========================================================

; Use Double Commander if available, otherwise default to Windows Explorer
FolderOpener := RunWait('where /q doublecmd') == 0 ? "doublecmd.exe --no-splash -C -T" : "explorer"

OpenFolder(folderName)
{
    Run FolderOpener . ' "' . folderName . '"'
}

UserHomeDirectory := EnvGet("UserProfile")

; Ctrl + Shift + J  --> Downloads 
^+J:: OpenFolder(UserHomeDirectory . "\Downloads")

; Ctrl + Shift + W  --> Workspace
^+W:: OpenFolder(UserHomeDirectory . "\Workspace")

; Ctrl + Shift + K  --> Kitchen Sink
^+K:: OpenFolder(A_MyDocuments . "\KitchenSink")

; Ctrl + Shift + P  --> Personal Backups
^+P:: OpenFolder(A_MyDocuments . "\Personal Backups")

; Ctrl + Shift + S  --> Sensitive Family Documents
^+S:: OpenFolder(A_MyDocuments . "\Sensitive Family Docs")

; Ctrl + Shift + T  --> -TEMP-
^+T:: OpenFolder(A_MyDocuments . "\-TEMP-")

; ========================================================
;       Actions --> Ctrl + Alt + .....
; ========================================================

; Ctrl + Alt + R --> Reload this AHK script
^!R:: Reload

; ========================================================
;       Miscellaneous functionality
; ========================================================

; Win + E --->  Override to open "This PC"
#E:: Run "shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"

; Ctrl + Win + V ---> Paste as plain text
^#v:: Send A_Clipboard
