RmForOSS() {
	rm -rf external/autotest
	rm -rf kernel/msm-4.14/tools/testing/
	rm -rf vendor/qcom/opensource/wlan/fw-api
	rm external/icu/icu4c/source/stubdata/icudt63l.dat

	find . -name .gitignore | xargs rm -v
	find . -name .gitattributes | xargs rm -v

	AllItems=".git .repo .github"
	for EachItem in $AllItems ; do
		echo ==== Removing folders named: $EachItem
		find . -type d -iname $EachItem | xargs rm -rf
	done

}

RmForOpenGrok() {
	rm -rf oss_report external prebuilts test toolchain tools

	AllItems="BTFM.CHE.2.1.5 BTFM.CMC.1.2.0 MPSS.AT.4.3 VIDEO.VE.5.4 WDSP.9340.3.0 WLAN.HL.3.0.1"
	for EachItem in $AllItems ; do
		echo ==== Removing AMSS: $EachItem
		rm -rf AMSS/$EachItem
	done

}

RmXXDirs() {
	AllItems="font fonts res test tests testdata win32 x86 x64"
	for EachItem in $AllItems ; do
		echo ==== Removing folders named: $EachItem
		find . -type d -iname $EachItem | xargs rm -rf
	done

	rm -rf sdk
	rm -rf dalvik/dx/tests
	rm -rf frameworks/base/tools/aapt2/integration-tests
	rm -rf frameworks/opt/gamesdk/third_party/

}

RmDOCs() {
	AllItems="README LICENSE NOTICE HISTORY OWNERS MODULE_LICENSE_APACHE2 image ChangeLog TEST_MAPPING"
	for EachItem in $AllItems ; do
		echo ==== Removing files named: $EachItem
		find . -type f -iname $EachItem | xargs rm -v
	done

	rm -rfv kernel/*/Documentation/
	rm -rfv frameworks/base/docs
}

RmSymLinks() {
	echo ==== Removing All symbolic link
	find -L . -xtype l | xargs rm -v
}

RmNoUseArch() {
	AllItems="alpha arc blackfin c6x cris frv h8300 hexagon ia64 m32r m68k metag microblaze mips mn10300 nios2 openrisc parisc powerpc s390 score sh sparc tile  um unicore32 x86 xtensa"
	for EachItem in $AllItems ; do
		echo ==== Removing kernel arch: $EachItem
		rm -rf kernel/msm-4.14/arch/$EachItem
	done
}

RmNoUseDevice() {
	AllItems="amlogic generic google google_car linaro sample"
	for EachItem in $AllItems ; do
		echo ==== Removing device items: $EachItem
		rm -rf device/$EachItem
	done

	AllItems="atoll msm8909 msm8909go msm8996 msmnile sdm845"
	for EachItem in $AllItems ; do
		echo ==== Removing device/com items: $EachItem
		rm -rf device/qcom/$EachItem
	done
}

RmNoUseHardware() {
	AllItems="google invensense nxp st ti"
	for EachItem in $AllItems ; do
		echo ==== Removing hardware folder: $EachItem
		rm -rf hardware/$EachItem
	done
}

RmNonCodeFiles() {
	AllItems="*.wav *.mp3 *.mp4 *.avi *.mov *.jpg *.bmp *.png *.ico *.gif *.m4a *.m4v"
	AllItems+="*.o *.obj *.S *.pyc *.lib *.so *.dll *.exe *.bat *.cmd *.apk *.sym *.aar *.pdb *.pcm *.whl *.ko"
	AllItems+="*.mailmap *.cocciconfig *.hprof *.out *.tsv *.eps *.miff *.xxd *.rdp *.efi *.cov *.model *.readme"
	AllItems+="*.md *.doc *.compiled *.ttc *.ttf *.html *.css *.pdf *.docx *.xsl *.ppt *.csv *.txt *.data *.json *.log *.sax *.pbtxt *.asm"
	AllItems+="*.zip *.7z *.jar *.tgz *.tar *.gz *.bz2"
	for EachExt in $AllItems ; do
		echo ==== Removing ext file: $EachExt
		find . -iname $EachExt | xargs rm -v
	done
}

FindFileBySize() {
	find . -type f -size +$*
}

GenReleaseCode() {
	RmForOSS
	RmXXDirs
	RmDOCs
	RmSymLinks
	RmNoUseArch
	RmNoUseDevice
	RmNoUseHardware
	RmNonCodeFiles
}