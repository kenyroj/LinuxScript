INIT() {
	source build/envsetup.sh
	lunch sdm660_64-userdebug
}

function Build() {
	LOG_NAME=Log.Build.`date +"%Y%m%d-%H%M%S"`.txt
	INIT
	make $* | tee $LOG_NAME
}

function MMM() {
	LOG_NAME=Log.Build.`date +"%Y%m%d-%H%M%S"`.txt
	INIT
	mmm $* | tee $LOG_NAME
}
