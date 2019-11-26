SAFE_FILE=/data/apbcrdd5/.DiskUsage

echo Disk usage last check date: `date +"%Y/%m/%d %H-%M-%S"`. > $SAFE_FILE
df -H  | grep -e Filesystem -e sdb1 >> $SAFE_FILE
echo ============================================================= >> $SAFE_FILE
cd /data
du -h --max-depth=1 -BM | sort -n >> $SAFE_FILE
