#!/bin/bash


PWD=$(pwd)
. ${PWD}/.myconfig.sh
tag=${1:-2024-06-12}
case $USER in
  codespace)
  WORKSPACE=/workspaces
  ;;
  *)
  WORKSPACE=$PWD
  ;;
esac
  
# pull the docker if necessary

docker pull $space/$repo:$tag

docker run -v $WORKSPACE:/home/rstudio --entrypoint="/bin/bash" -w /home/rstudio/programs -t --rm $space/$repo:$tag ./run_all.sh
