import subprocess

application_class        = 'obsidian.obsidian'
application_flatpak_name = 'md.obsidian.Obsidian'

window.activate(application_class, switchDesktop=True, matchClass=True)

time.sleep(.1)

if application_class not in window.get_active_class():
    subprocess.Popen(['flatpak', 'run', application_flatpak_name])    
