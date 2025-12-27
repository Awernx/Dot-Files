import os
import subprocess

# Configuration Items
rofi_theme = 'yellow-line'
rofi_prompt = 'Select URL to launch: '

bookmarks = {
    'Awernx gmail'          : 'https://mail.google.com/mail/u/1/#inbox',
    'Calendar'              : 'https://calendar.google.com/calendar/u/0/r',
    'Google drive'          : 'https://drive.google.com/drive/u/0/',
    'Google Meet'           : 'https://meet.google.com/',
    'Expense sheet'         : 'https://docs.google.com/spreadsheets/d/1GdOmDZf2xKY06dflQC17XiihZ4mirsm5T_2nKDQ8juE',
    'HDFC banksheet'        : 'https://docs.google.com/spreadsheets/d/1oXGTnOp7kcpqkrMPKGCU0_NsxFNBcwo3e5tnt1CizfI',
    'HDFC'                  : 'https://netbanking.hdfcbank.com/',
    'Prepaid HDFC'          : 'https://hdfcbankprepaid.hdfcbank.com/hdfcportal/index',
    'DCU'                   : 'https://www.dcu.org/',
    'Capital One'           : 'https://www.capitalone.com/',
    'Zoho'                  : 'https://mail.zoho.com/',
    'Router'                : 'http://192.168.1.1/',
    'GitHub'                : 'https://github.com/',
    'Syncthing'             : 'http://127.0.0.1:8384/',
    'LUIS'                  : 'https://www.luis.ai/applications/25b46c93-1db0-48c9-9a47-ce0c8118342a/versions/0.1/build/intents',
    'Sillarai Repo'         : 'https://github.com/Sillarai/WebPay',
    'Tintinnabulator Repo'  : 'https://github.com/Awernx/Tintinnabulator',
    'Beanstalk'             : 'https://console.aws.amazon.com/elasticbeanstalk/home',
    'Cloud Watch'           : 'https://console.aws.amazon.com/cloudwatch/home',
    'Lambda'                : 'https://console.aws.amazon.com/lambda/home',
    'API Gateway'           : 'https://console.aws.amazon.com/apigateway/home',    
}

try:    
    ps = subprocess.Popen(('echo', "\n".join(bookmarks)), stdout=subprocess.PIPE)
    output = subprocess.run(['rofi', '-dmenu', '-i','-p', rofi_prompt, '-theme', rofi_theme], stdin=ps.stdout, check=True, capture_output=True, text=True).stdout
    ps.wait()
except subprocess.CalledProcessError as e:
    output = str(e.output)   

output = output.strip()

if output and output in bookmarks:
    os.system('xdg-open "'+ bookmarks[output] + '"')
