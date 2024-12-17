#!/bin/bash
# Shows UsedSpace(in Byte)

#Used=$((`df -k | grep data$ | sed 's/  */ /g' | cut -d ' ' -f 3` * 1))
#Total=$((`df -k | grep data$ | sed 's/  */ /g' | cut -d ' ' -f 2` * 1))
AvailData=$((`df -l -k | grep data$ | sed 's/  */ /g' | cut -d ' ' -f 4`))
AvailRoot=$((`df -l -k | grep /$ | sed 's/  */ /g' | cut -d ' ' -f 4`))
echo $AvailData
echo $AvailRoot
