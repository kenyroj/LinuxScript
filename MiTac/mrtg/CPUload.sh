#!/bin/bash
# Shows CPU Avreare loading (in 1/10000)

echo $[100-$(vmstat 1 2|tail -1|awk '{print $15}')]
echo 100
