import os

password_file = os.path.expanduser( '~/.cache/awernx/unp.rag' )

with open(password_file) as f:
    password = f.read()
    
keyboard.send_keys(password)
