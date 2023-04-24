open -a XQuartz
xhost +localhost
docker run --rm -it -e DISPLAY=docker.for.mac.host.internal:0 --volume=$HOME/soft/geant4-data:/opt/geant4/data:ro carlomt/geant4:latest-gui bash

