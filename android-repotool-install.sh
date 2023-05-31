#!/bin/bash
# Make sure only root can run our script
if [[ $EUID == 0 ]]; then
   echo "This script must be run as Normal User" 1>&2
   exit 1
else
mkdir -p ~/.bin
PATH="${HOME}/.bin:${PATH}"
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo

fi
