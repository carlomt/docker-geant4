xhost local:root
docker run --rm -it -e DISPLAY=$DISPLAY  -v /tmp/.X11-unix:/tmp/.X11-unix --volume=/home/soft/geant4-data:/opt/geant4/data carlomt/geant4:latest-gui bash


