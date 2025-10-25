## 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# -----------------------------------------------
#  AWK script that parses 'ip address' output
#  to extract IP addresses and MAC address 
#  Note: Script accepts device types as param
#
#  Usage: ip address | 
#          awk -f ip-address.awk

BEGIN {
  deviceTypes["en"]="Ethernet"
  deviceTypes["wl"]="Wi-Fi"
}

{
  processCurrentLine()

  while(getline) {
    processCurrentLine()
  }
}

# End of file reached; Print last device details
END {
  printDeviceDetails()
}

function processCurrentLine() {
  if ($1 ~ /^[0-9]/) {
    # Print out curent device details
    printDeviceDetails()

    #  Initialize new device
    deviceName = substr($2, 1, length($2)-1);
    deviceNameAbbr = substr($2, 1, 2); #First 2 characters
    v4=v6=""
  }
  else if ($1 == "inet") {
    v4 = $2
    sub(/\/[0-9]*/, "", v4) # Remove trailing subnet mask
  }
  else if ($1 == "inet6") {
    v6 = $2
    sub(/\/[0-9]*/, "", v6) # Remove trailing subnet mask
  }
  else if ($1 ~ /^link\//) {
    mac = $2
  }
}

function printDeviceDetails() {
  if (deviceName != "" && (v4 != "" || v6 != "") && v4 != "127.0.0.1" && v6 != "::1") {

    if (deviceTypes[deviceNameAbbr] != "")
      print "\n    Adapter: " deviceTypes[deviceNameAbbr] " [" deviceName "]"
    else 
      print "\n    Adapter: " deviceName # Ignore device type if not supplied

    if(v4 != "")
      print "      IP v4: " v4
   
    if(v6 != "")
      print "      IP v6: " v6 

    print "        MAC: " mac
  }

}
