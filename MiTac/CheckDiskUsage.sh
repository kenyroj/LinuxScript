SAFE_FILE=/data/apbcrdd5/.DiskUsage

echo Disk usage last check date: `date +"%Y/%m/%d %H-%M-%S"`. > $SAFE_FILE

cd /data
du -h --max-depth=1 -BM | sort -n >> $SAFE_FILE

