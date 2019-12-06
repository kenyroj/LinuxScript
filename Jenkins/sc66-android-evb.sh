echo ======== Variables of Jenkins ========
echo BRANCH_NAME=$BRANCH_NAME
echo BUILD_NUMBER=$BUILD_NUMBER
echo JENKINS_URL=$JENKINS_URL
echo BUILD_URL=$BUILD_URL

echo ======== Variables From Parameters ========
echo DailyManifest=$DailyManifest
echo BranchName=$BranchName
echo BuildVariant=$BuildVariant
echo BuildDist=$BuildDist

echo ======== ENV Setting for Jenkins ========
export USE_CCACHE=1
export CCACHE_DIR=/mnt/nfs/CCache
export PATH=$PATH:.
GERRIT_URL=gerrit://main.apbcrdd5.mdt
PRJ_NAME=$BranchName
BUILD_TYPE="daily"

if [ ! -z $DailyManifest ] ; then
	BUILD_TIME=$DailyManifest
else
	BUILD_TIME=`date +"%Y%m%d-%H%M%S"`
fi

ANDROID_FOLDER=Android
NHLOS_FOLDER=NonHLOS
SRC_HOME=/data/src
DPL_HOME=/mnt/nfs/Jenkins
BUILD_NAME=${PRJ_NAME}-${BUILD_TYPE}-${BUILD_TIME}
SRC_PATH=$SRC_HOME/$BUILD_NAME
DPL_PATH=$DPL_HOME/$PRJ_NAME/$BUILD_TYPE

mkdir -p $SRC_PATH
cd $SRC_PATH
mkdir $ANDROID_FOLDER
cd $ANDROID_FOLDER

echo ======== Fetch Code ========
if [ ! -z $DailyManifest ] ; then
	REPO_MANIFEST="-m daily/$DailyManifest.xml"
fi
repo init -u $GERRIT_URL/manifest.git -b $PRJ_NAME $REPO_MANIFEST --reference /mnt/nfs/CodeAuroraMirror/
repo sync -c -j4

echo ======== Start Building ========
if [ $BuildDist ] ; then
	DIST="dist"
else
	DIST=""
fi

source build/envsetup.sh
lunch sdm660_64-$BuildVariant
make -j8 $DIST

echo ======== Generate flat_bin Image ========
cd ..
git clone -b $PRJ_NAME $GERRIT_URL/sc66-nhlos-prebuilt $NHLOS_FOLDER
cd $NHLOS_FOLDER
bash update_common_build.sh ../$ANDROID_FOLDER

echo ======== Deploy Built Image ========
cd flat_bin
mkdir -p $DPL_PATH
zip -r $DPL_PATH/${BUILD_NAME}.zip *

echo ======== Deploy dist image ========
if [ $BuildDist ] ; then
	cd $SRC_PATH
	cd $ANDROID_FOLDER
	cp out/target/product/sdm660_64/obj/PACKAGING/target_files_intermediates/sdm660_64-target_files-eng.*.zip ./sdm660_64-target_files-eng.${BUILD_NAME}.zip
	./build/tools/releasetools/ota_from_target_files -v --block -p out/host/linux-x86 -k build/target/product/security/testkey sdm660_64-target_files-eng.${BUILD_NAME}.zip FullOTAupdate.${BUILD_NAME}.zip
    mv sdm660_64-target_files-eng.${BUILD_NAME}.zip $DPL_PATH/
    mv FullOTAupdate.${BUILD_NAME}.zip $DPL_PATH/
fi

echo ======== Rm Built Codes ========
cd $SRC_HOME
rm -rf $SRC_PATH
