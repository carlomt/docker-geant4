# docker-geant4

## Docker container with Geant4 for amd64 and arm64

you can download this container with:

`docker pull carlomt/geant4`

### Geant4 datasets

To keep the size of the Docker images limited, the Geant4 datasets are not installed. They are expect to be found in
`/opt/geant4/data`
I suggest you to map a folder in the host to use always the same dataset with the option:

`--volume=<GEANT4_DATASETS_PATH>:/opt/geant4/data:ro`

If some, or all, are missing it is possible to install the datasets from the docker with:

`geant4-config --install-datasets`

in this case, if you want to dowload the datasets in a host folder, you must mount the volume without the read-only flag:

`--volume=<GEANT4_DATASETS_PATH>:/opt/geant4/data`

The image will check the datasets at login, 

`geant4-config  --install-datasets`

### Geant4 examples

To save space, Geant4 examples have been removed, to download them:

`wget https://gitlab.cern.ch/geant4/geant4/-/archive/master/geant4-master.tar.gz?path=examples -O examples.tar.gz && tar xf examples.tar.gz --strip-components 1`

## GUI

the tags ending with `-gui` have also the graphic enabled, to download the last one:

`docker pull carlomt/geant4:latest-gui`

to use the GUI you need to allow X11 forwarding with GLX acceleration (to see the geometry)

### Linux
Add local connections to X11 access control list:

`xhost local:root`

Run the docker container mapping /tmp/.X11-unix to the image and the display:
```
docker run --rm -it -e DISPLAY=$DISPLAY  --volume /tmp/.X11-unix:/tmp/.X11-unix --volume=<GEANT4_DATASETS_PATH>:/opt/geant4/data:ro carlomt/geant4:latest-gui bash
```

### Mac
Install XQuartz

start XQuartz:

`open -a XQuartz`

go to XQuartz->Settings and in the `Security` panel enable `Allow connections from network clients`

restart XQuartz:

Check where the XQuartz config file, or domain, is located with:

`quartz-wm --help`

which should output:
```
usage: quartz-wm OPTIONS
Aqua window manager for X11.

--version                 Print the version string
--prefs-domain <domain>   Change the domain used for reading preferences
                          (default: org.xquartz.X11
```
The last line shows the default domain, in this case `org.xquartz.X11`. Before XQuartz 2.8.0 the default domain was: `org.macosforge.xquartz.X11`.
You can check the default domain  with:
```
defaults read org.xquartz.X11
```
To have GLX acceleration you must enable it with:
```
defaults write org.xquartz.X11 enable_iglx -bool true
```
restart XQuartz again. You can check if GLX is now enabled again with:
```
defaults read org.xquartz.X11
```
Finally, you have to allow X11 forwarding to local containers:
```
xhost +localhost
```
the latter command has to be executed every time XQuartz is restarted.

Finally you can run the docker container:
```
docker run --rm -it -e DISPLAY=docker.for.mac.host.internal:0 --volume=<GEANT4_DATASETS_PATH>:/opt/geant4/data:ro carlomt/geant4:latest-gui bash
```
