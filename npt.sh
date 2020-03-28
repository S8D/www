#!/bin/bash
# Program name: pingall.sh
npt="./npt.txt"
date
cat $npt | while read output
do
    ping -c 1 "$output" > /dev/null
    if [ $? -eq 0 ]; then
    echo "# ONLINE  + $output" 
    else
    echo "# OFFLINE - $output"
    fi
done