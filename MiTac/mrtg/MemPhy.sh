#!/bin/bash
# Shows UsedSpace(in Byte)

echo $((`free | grep Mem | sed 's/  */ /g' | cut -d ' ' -f 4` * 1))
echo $((`free | grep Mem | sed 's/  */ /g' | cut -d ' ' -f 3` * 1))
