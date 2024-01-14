# docker-geant4

## Docker container with Geant4 for amd64 and arm64

I suggest to use this container using Docker Compose, see the last section of this file.

You can also download manually this container with:

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

### Geant4 examples

To save space, Geant4 examples have been removed, to download them:

`curl https://gitlab.cern.ch/geant4/geant4/-/archive/geant4-\`/opt/geant4/bin/geant4-config --version | awk -F '.' '{print $1"."$2}'\`-release/geant4-master.tar.gz?path=examples --output examples.tar.gz && tar xf examples.tar.gz --strip-components 1`

## GUI

the tags ending with `-gui` have also the graphic enabled, to download the last one:

`docker pull carlomt/geant4:latest-gui`

to use the GUI you need to allow X11 forwarding with GLX acceleration (to see the geometry)

### Linux
Add local connections to X11 access control list:

`xhost local:root`

I suggest you to use Docker Compose (see later) otherwise, run the docker container mapping /tmp/.X11-unix to the image and the display:
```
docker run --rm -it -e DISPLAY=$DISPLAY  --volume /tmp/.X11-unix:/tmp/.X11-unix --volume=<GEANT4_DATASETS_PATH>:/opt/geant4/data:ro carlomt/geant4:latest-gui bash
```

### Windows
If you don't have X11 already installed (it should be on the latest versions of Windows 11), download XMing from

https://sourceforge.net/projects/xming/

I suggest you to use Docker Compose (see later), otherwise use the Powershell terminal to launch docker:
```
docker run --rm -it -e DISPLAY=docker.host.internal:0 --volume=<GEANT4_DATASETS_PATH>:/opt/geant4/data:ro carlomt/geant4:latest-gui bash
```

### Mac
Install XQuartz

https://www.xquartz.org/

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

I suggest you to use Docker Compose (see later), otherwise you can run the docker container:
```
docker run --rm -it -e DISPLAY=docker.for.mac.host.internal:0 --volume=<GEANT4_DATASETS_PATH>:/opt/geant4/data:ro carlomt/geant4:latest-gui bash
```

## Compose

To simplify the use of these images we developed a Docker Compose file, to use it donwload it to a folder from

https://raw.githubusercontent.com/carlomt/docker-geant4/main/docker-compose.yml

if you want to use curl from the terminal:
```
curl https://raw.githubusercontent.com/carlomt/docker-geant4/main/docker-compose.yml --output docker-compose.yml
```

in the same folder, download one of the following files accordingly to your operating system:

- linux
```
curl https://raw.githubusercontent.com/carlomt/docker-geant4/main/env_linux --output .env
```
- windows
```
curl https://raw.githubusercontent.com/carlomt/docker-geant4/main/env_windows --output .env
```
- mac
```
curl https://raw.githubusercontent.com/carlomt/docker-geant4/main/env_mac --output .env
```

run:
`docker compose run prepare`

it will create the subfolders, download the Geant4 datasets and source code. Once it has finished, you can run the Geant4 container:

`docker compose run geant4`

The home in the container is mapped to a subfolder called `workdir` created in the folder where you placed the `docker-compose.yml` and `.env` files

Docker Compose should automatically create some subfolders needed if they are not existing, namely: `geant4-datasets` and `workdir`. Some version of Docker do not create the directories and gives an error, in case create them by hand:

`mkdir geant4-datasets`

`mkdir workdir`

If you need the Geant4 GUI (once you installed the needed preliminary software on your host opearing system as described in the dedicated section of this file), you can run the docker with:

`docker compose run geant4-gui`

Remember that still you should enable the X11 forwarding every time you reboot (or restart the X11 server)

`xhost local:root` on linux

`xhost +localhost` on mac

You can check X11 forwarding with:

`docker compose run xeyes`

and 3D acceleration with:

`docker compose run gears`

