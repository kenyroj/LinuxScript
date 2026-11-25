CM_KEEP_DAY=14
DA_KEEP_DAY=180
RL_UD_KEEP_DAY=7	# release 裡的 userdebug 保留天數 (n689)

ScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
source "$ScriptDir/Common.sh"


Main() {
	if [ "$1" = "1" ] ; then
		IsDelete="1"
	else
		IsDelete="0"
	fi

	AllDir=""
	AllDir+="n836-yocto40-dev/ "
	AllDir+="n868-ubuntu22-dev/ n868-yocto40-dev/ "
	AllDir+="n875-l5.15.32_u22-dev/ n875-l5.15.32_y40-dev/ n875-l6.01.36_u22-dev/ n875-l6.01.55_u22-dev/ n875-l6.01.55_y50-dev/ n875-yocto40-dev/ "
	AllDir+="n748-android13-dev sg560devb-android13-dev "
	AllDir+="qcs610-android-evb-dev qcs610-android12-dev "

	AllDir+="n702-android-aapexdemo "
	AllDir+="n702-android-smarterai "
	AllDir+="n702-android-dev "
	AllDir+="n702-android-bms "
	AllDir+="n702-android-tn "
	AllDir+="n702-android-5g "
	AllDir+="n702-android-geotab "
	AllDir+="n702-android-dsny "

	AllDir+="n706-android-dev/ "
	AllDir+="n706-android-onaz_a/ "
	AllDir+="n706-android-onaz_d/ "
	AllDir+="n706-android-pcba/ "
	AllDir+="n706-android-testota_onaz_a/ "
	AllDir+="n706-android-testota_onaz_d/ "

	AllDir+="n689-android-axis/ "
	AllDir+="n689-android-b2b/ "
	AllDir+="n689-android-dd/ "
	AllDir+="n689-android-dev/ "
	AllDir+="n689-android-nec/ "
	AllDir+="n689-android-pcba/ "
	AllDir+="n689-android-smas/ "
	AllDir+="n689-android-go/ "
	AllDir+="n689-android-testota/ "
	AllDir+="n689-android-testota_b2b "
	AllDir+="n689-android-testota_dd "
	AllDir+="n689-android-testota_nec "
	AllDir+="n689-android-testota_smas "
	for EachDir in $AllDir ; do
		echo DIR: $EachDir
		ExeCmd python3 $ScriptDir/DeleteOldFile.py /data/Images/$EachDir/custom/	$CM_KEEP_DAY $IsDelete
		ExeCmd python3 $ScriptDir/DeleteOldFile.py /data/Images/$EachDir/daily/	$DA_KEEP_DAY $IsDelete

	done

	ExeCmd python3 $ScriptDir/DeleteOldFile.py '/data/Images/custom-changenote/'	$CM_KEEP_DAY $IsDelete

	# n689 daily 依政策會同步到 release, 裡面的 userdebug 只保留 RL_UD_KEEP_DAY 天
	# n689-android-pcba 本來就只出 userdebug, 不清
	if [ "$IsDelete" = "1" ] ; then FindAct="-print -delete" ; else FindAct="-print" ; fi
	for EachDir in n689-android-axis n689-android-b2b n689-android-dd n689-android-dev n689-android-nec n689-android-smas ; do
		echo DIR: $EachDir/release userdebug
		[ -d /data/Images/$EachDir/release/ ] || continue
		ExeCmd find /data/Images/$EachDir/release/ -maxdepth 1 -type f -name '*-userdebug-*' -ctime +$RL_UD_KEEP_DAY $FindAct
	done
}

Main $*
