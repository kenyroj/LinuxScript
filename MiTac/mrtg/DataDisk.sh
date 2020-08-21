#!/bin/bash
# Shows UsedSpace(in Kb)

echo $((`df -k | grep dev/sdb1 | sed 's/  */ /g' | cut -d ' ' -f 3` * 1))
echo $((`df -k | grep dev/sdb1 | sed 's/  */ /g' | cut -d ' ' -f 2` * 1))
echo `/usr/bin/uptime | awk '{print $3 " " $4 " " $5}'`
echo $HOSTNAME
