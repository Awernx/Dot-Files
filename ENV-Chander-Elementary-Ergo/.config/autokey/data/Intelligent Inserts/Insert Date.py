from datetime import datetime

# current date and time
date_time = datetime.now().strftime("%m/%d/%Y")

keyboard.send_keys(date_time)
