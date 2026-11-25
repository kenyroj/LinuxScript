#!/bin/bash

Main() {
	cd /mnt/nfs/QCS610AndroidMirror/ || return 1
	rm -rf .repo
	bash repo_cmd.la10
	repo sync
	rm -rf .repo
	bash repo_cmd.la20
	repo sync
}

Main