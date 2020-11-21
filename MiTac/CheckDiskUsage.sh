SAFE_FILE=/home/.DiskUsage
DST_PATH=/data

echo Disk usage last check date: `date +"%Y/%m/%d %H-%M-%S"`. > $SAFE_FILE
df -H  | grep -e Filesystem -e $DST_PATH >> $SAFE_FILE
echo ============================================================= >> $SAFE_FILE
cd $DST_PATH
du -h --max-depth=1 -BM | sort -n >> $SAFE_FILE
