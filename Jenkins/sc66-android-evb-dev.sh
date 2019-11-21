echo ======== Variables of Jenkins ========
BRANCH_NAME=$1
BUILD_NUMBER=$2
JENKINS_URL=$3
BUILD_URL=$4

echo $BRANCH_NAME=$1
echo $BUILD_NUMBER=$2
echo $JENKINS_URL=$3
echo $BUILD_URL=$4

echo ======== ENV Setting for Jenkins ========
export PATH=$PATH:.

PRJ_NAME=sc66-android-evb-dev
BUILD_TYPE=daily
BUILD_TIME=`date +"%y%m%d-%H%M%S"`
ANDROID_FOLDER=Android
NHLOS_FOLDER=NonHLOS
SRC_PATH=/data/src/${PRJ_NAME}-${BUILD_TIME}
DPL_PATH=/mnt/nfs/Jenkins/$PRJ_NAME/$BUILD_TYPE

mkdir -p $SRC_PATH
cd $SRC_PATH
mkdir $ANDROID_FOLDER
cd $ANDROID_FOLDER

echo ======== Fetch Code ========
repo init -u gerrit://main.apbcrdd5.mdt/manifest.git -b sc66-android-evb-dev --reference /mnt/nfs/CodeAuroraMirror/
repo sync

echo ======== Start Building ========
source build/envsetup.sh
lunch sdm660_64-userdebug
make -j4

echo ======== Generate flat_bin Image ========
cd ..
git clone -b sc66-android-evb-dev gerrit://main.apbcrdd5.mdt/sc66-nhlos-prebuilt $NHLOS_FOLDER
cd $NHLOS_FOLDER
bash update_common_build.sh ../$ANDROID_FOLDER

echo ======== Deploy Built Image ========
cd flat_bin
mkdir -p $DPL_PATH
zip -r $DPL_PATH/${PRJ_NAME}-${BUILD_TYPE}-${BUILD_TIME}.zip *

cd ../..
rm -rf $SRC_PATH
