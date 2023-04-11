BOOT_INTERVAL=100
BOOT_COUNT=0
DEF_COUNT=6

unset MAX_COUNT
if [ -z "$1" ] ; then
	MAX_COUNT=$DEF_COUNT
else
	MAX_COUNT=$1
fi
echo MAX_COUNT=$MAX_COUNT

while [ 1 ] ; do
	((BOOT_COUNT=BOOT_COUNT+1))
	echo [$(date +"%m%d-%H%M%S")] Reboot android device for $BOOT_COUNT times.
	adb wait-for-device reboot
	echo [$(date +"%m%d-%H%M%S")] Waiting for $BOOT_INTERVAL seconds
	
	if [ $MAX_COUNT -eq $BOOT_COUNT ] ; then
		break
	fi
	
	sleep $BOOT_INTERVAL
done

adb wait-for-device shell setprop vendor.logsave.util 2
adb wait-for-device shell "cd logsave ; grep -r 'Boot c' *"