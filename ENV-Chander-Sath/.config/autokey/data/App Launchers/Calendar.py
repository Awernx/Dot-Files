import subprocess

application_class = 'io.elementary.calendar.Io.elementary.calendar'
application_name  = 'io.elementary.calendar'

window.activate(application_class, switchDesktop=True, matchClass=True)

time.sleep(.1)

if application_class not in window.get_active_class():
    subprocess.Popen([application_name])    
