import os
import subprocess

# Configuration Items
rofi_theme = 'purple-line'
rofi_prompt = 'Select Workspace to open in VS Code: '

bookmarks = {
    'WebPay'            : '~/Workspace/WebPay',
    'Artwork Sillarai'  : '~/Workspace/Artwork',
    'Linux Dot Files'   : '~/Workspace/Linux-DotFiles',
    'Machine Settings'  : '~/Workspace/machine-settings',
    'Resource Files'    : '~/Workspace/ResourceFiles',
    'Tintinnabulator'   : '~/Workspace/Tintinnabulator',
    'Legacy Sillarai'   : '~/Workspace/Sillarai-Web-Application',
    'Swell'             : '~/Workspace/Swell',
    'Jeeves'            : '~/Workspace/Jeeves',
    'Commons'           : '~/Workspace/Commons',
    'Finsight'          : '~/Workspace/Finsight',
    'Cockpit'           : '~/Workspace/Cockpit',
    'Scroll'            : '~/Workspace/Scroll',
    'Ingress'           : '~/Workspace/Ingress'
}

try:    
    ps = subprocess.Popen(('echo', "\n".join(bookmarks)), stdout=subprocess.PIPE)
    output = subprocess.run(['rofi', '-dmenu', '-i','-p', rofi_prompt, '-theme', rofi_theme], stdin=ps.stdout, check=True, capture_output=True, text=True).stdout
    ps.wait()
except subprocess.CalledProcessError as e:
    output = str(e.output)   

output = output.strip()

if output and output in bookmarks:
    os.system('/usr/bin/code --new-window '+ bookmarks[output])
