import os
import subprocess

from paramiko import SSHConfig

# Configuration Items
terminal_program = 'io.elementary.terminal'
terminal_program_options = '-x'
rofi_theme = 'dmenu'
rofi_prompt = 'Select server to SSH into: '

exclude_list = ['*', 'github.com']
ssh_config_file = os.path.expanduser( '~/.ssh/config' )

ssh_config = SSHConfig()
    
if os.path.exists( ssh_config_file ):
    with open( ssh_config_file ) as fh:
        ssh_config.parse( fh )
else:
    raise MissingConfigurationFile( ssh_config_file )

host_list = set(ssh_config.get_hostnames()) - set(exclude_list)

try:    
    ps = subprocess.Popen(('echo', "\n".join(host_list)), stdout=subprocess.PIPE)
    output = subprocess.run(['rofi', '-dmenu', '-i', '-p', rofi_prompt, '-theme', rofi_theme], stdin=ps.stdout, check=True, capture_output=True, text=True).stdout
    ps.wait()
except subprocess.CalledProcessError as e:
    output = str(e.output)

output = output.strip()

if output and output in host_list:
    subprocess.Popen([terminal_program, terminal_program_options, 'ssh', output])
