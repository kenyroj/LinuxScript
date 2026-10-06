#!/bin/bash
# Shows available and total physical memory (in KB)

free | awk '/^Mem/ {print $7; print $2}'
