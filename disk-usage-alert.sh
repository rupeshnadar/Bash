#!/bin/bash

# Check disk usage excluding snap directory
# Space Alert is triggered for usage above 60%

df -Ph | grep -v "snap" | sed s/%//g | awk '{ if($5 > 60) print $0;}'

exit 0

