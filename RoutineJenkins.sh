

Main() {
	cd /mnt/nfs/QCS610AndroidMirror/
	rm -rf .repo
	`cat repo_cmd.la10`
	repo sync
	rm -rf .repo
	`cat repo_cmd.la20`
	repo sync
	
}

Main