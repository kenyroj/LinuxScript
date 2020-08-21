#!/bin/bash
# Shows UsedSpace(in Byte)

echo $((`df -k | grep dev/sdb1 | sed 's/  */ /g' | cut -d ' ' -f 3` * 1))
echo $((`df -k | grep dev/sdb1 | sed 's/  */ /g' | cut -d ' ' -f 2` * 1))
