#!/bin/bash
# Program name: pingall.sh
npt="./npt.txt"
date
cat $npt | while read server
do
    #ping -c 1 "$server" > /dev/null
    ping -c 1 -t 1 "$server" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
    echo "# ONLINE  + $server" 
    else
    echo "# OFFLINE - $server"
    fi
done