NOW_TIME=`date +"%Y%m%d-%H%M%S"`

INIT() {
	source build/envsetup.sh
	lunch sdm660_64-userdebug
}

function Build() {
	LOG_NAME=Log.Build.$NOW_TIME.txt
	INIT
	make $* | tee $LOG_NAME
}

