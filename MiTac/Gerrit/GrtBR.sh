Usage() {
cat << EOF
Usage: Param1:
 - B: for backup
 - R: for restore
EOF
}

RSync() {
	rsync -av --delete $1/* $2 
}

Backup() {
	RSync /data/Repositories    /mnt/smb/CmBackUp/Repos/
	RSync /home/gerrit/MainSite	/mnt/smb/CmBackUp/Site/
}

Restore() {
	RSync /mnt/smb/CmBackUp/Repos/ /data/GrtRepo
	RSync /mnt/smb/CmBackUp/Site/  /data/GrtSite
}

if [ "$1" == "" ] ; then 
	echo Need 1 Param
	Usage
#	return 1
elif [ "$1" == "B" -o "$1" == "b" ] ; then 
	Backup
elif [ "$1" == "R" -o "$1" == "r" ] ; then 
	Restore
else
	echo Wrong param
	Usage
#	return 1
fi
