CM_KEEP_DAY=14
DA_KEEP_DAY=180

RunAndLog() {
	echo " ===> EXEC: [1;33m$*[m"
	$*
	return ${PIPESTATUS[0]}
}


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

	AllDir+="n702-android-aapexdemo "
	AllDir+="n702-android-smarterai "
	AllDir+="n702-android-dev "
	AllDir+="n702-android-bms "
	AllDir+="n702-android-tn "
	AllDir+="n702-android-5g "
	AllDir+="n702-android-geotab "

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
	AllDir+="n689-android-pcba/ "
	AllDir+="n689-android-go/ "
	AllDir+="n689-android-testota/ "
	AllDir+="n689-android-testota_axi "
	for EachDir in $AllDir ; do
		echo DIR: $EachDir
		RunAndLog python3 /data/aken.hsu/script/DeleteOldFile.py /data/Images/$EachDir/custom/	$CM_KEEP_DAY $IsDelete
		RunAndLog python3 /data/aken.hsu/script/DeleteOldFile.py /data/Images/$EachDir/daily/	$DA_KEEP_DAY $IsDelete

	done

	RunAndLog python3 /data/aken.hsu/script/DeleteOldFile.py '/data/Images/custom-changenote/'	$CM_KEEP_DAY $IsDelete
}

Main $*
