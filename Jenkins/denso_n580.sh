echo ======== Variables of Jenkins ========
echo BRANCH_NAME=$BRANCH_NAME
echo BUILD_NUMBER=$BUILD_NUMBER
echo JENKINS_URL=$JENKINS_URL
echo BUILD_URL=$BUILD_URL

echo ======== ENV Setting for Jenkins ========
export MITAC_CHECK_ENV_SOURCE=n
g_build_auto_run=y
export PATH=$PATH:.

PRJ_NAME=denso_n580
BUILD_TYPE=daily
BUILD_TIME=`date +"%y%m%d-%H%M%S"`
SRC_PATH=/data/src/${PRJ_NAME}-${BUILD_TIME}
IMG_PATH=apps_proc/oe-core/build/tmp-glibc/deploy/images/apq8009
DPL_PATH=/mnt/Jenkins/$PRJ_NAME/$BUILD_TYPE


echo ======== Start building ========
source ~/init/repo_manager.sh
mkdir -p $SRC_PATH
cd $SRC_PATH

rimp -p denso -d 5 -t .
repo sync

source ./mitac_project_env.sh -p denso --docker
ball -a -j4


echo ======== Deploy Built Image ========
cd $IMG_PATH
mkdir -p $DPL_PATH
zip -r $DPL_PATH/${PRJ_NAME}-${BUILD_TYPE}-${BUILD_TIME}.zip *

cd ..
rm -rf $SRC_PATH
