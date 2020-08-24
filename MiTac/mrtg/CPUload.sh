#!/bin/bash
# Shows CPU Avreare loading (in 1/10000)

echo `mpstat | tail -1 | sed 's/  */ /g' | cut -d ' ' -f 4 | awk '{print($1)}'`
echo `mpstat | tail -1 | sed 's/  */ /g' | cut -d ' ' -f 6 | awk '{print($1)}'`
