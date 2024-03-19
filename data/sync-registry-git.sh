#!/bin/bash

dest=registry
srcrepo=J-PAL/AEA_registryanalysis
srcurl=https://github.com/${srcrepo}/archive/refs/heads/main.zip

# switch to using gh

if [[ -d $dest ]]
then
   cd $dest
   gh repo sync
   cd -
else
   gh repo clone $srcrepo $dest
fi

# add it all back

git add $dest
