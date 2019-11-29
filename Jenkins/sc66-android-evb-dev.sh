echo ======== Variables of Jenkins ========
echo BRANCH_NAME=$BRANCH_NAME
echo BUILD_NUMBER=$BUILD_NUMBER
echo JENKINS_URL=$JENKINS_URL
echo BUILD_URL=$BUILD_URL

echo ======== Variables From Parameters ========
echo DailyManifest=$DailyManifest
echo BranchName=$BranchName

echo ======== ENV Setting for Jenkins ========
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
source build/envsetup.sh
lunch sdm660_64-userdebug
make -j4

echo ======== Generate flat_bin Image ========
cd ..
git clone -b $PRJ_NAME $GERRIT_URL/sc66-nhlos-prebuilt $NHLOS_FOLDER
cd $NHLOS_FOLDER
bash update_common_build.sh ../$ANDROID_FOLDER

echo ======== Deploy Built Image ========
cd flat_bin
mkdir -p $DPL_PATH
zip -r $DPL_PATH/${BUILD_NAME}.zip *

cd $SRC_HOME
rm -rf $SRC_PATH
