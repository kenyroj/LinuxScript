#!/bin/bash
# Shows CPU average loading (in %), and the max value 100

echo $((100 - $(vmstat 1 2 | tail -1 | awk '{print $15}')))
echo 100
