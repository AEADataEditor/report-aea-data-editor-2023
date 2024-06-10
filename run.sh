#!/bin/bash

case $USER in
  vilhuber|larsvilhuber)
	  WORKSPACE=$(pwd)
  ;;
  codespace)
  WORKSPACE=/workspaces
  ;;
esac

PWD=$(pwd)
. ${PWD}/.myconfig.sh
tag=${1:-2023-12-05}
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

docker run -v $WORKSPACE:/home/rstudio --entrypoint="/bin/bash" -w /home/rstudio/programs -t --rm $space/$repo ./run_all.sh
