#!/bin/bash
# Shows available space (in KB) of data disk (vg1-lv1) and root

df -l -k | awk '/vg1-lv1/ {print $4}'
df -l -k | awk '$6 == "/" {print $4}'
