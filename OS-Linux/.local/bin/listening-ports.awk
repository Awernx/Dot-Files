# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# --------------------------------------
# AWK script to parse SS command output

# Header
BEGIN { print "Type\tPort\tProcess"}

# Skip lines starting with NetId
/^Netid/ {next}

# Print the Network type (udp/tcp), Port number and Process name
{ print $1, "\t", getPort($5), "\t", getProcessName($7)}

function getPort(address)
{
    indexVal=match( address, /:[^:]*$/)
    if (indexVal == 0)
        return ""
    return substr(address, indexVal+1)
}

function getProcessName(processDetails)
{
    start = index(processDetails, "\"")
    if (start == 0)
        return "<unknown>"

    processDetails = substr(processDetails, start+1)
    end = index(processDetails, "\"")
    if (end == 0)
        return ""

    return substr(processDetails, 1, end-1)    
}