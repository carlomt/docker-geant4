ARG BASE_IMAGE=ubuntu:jammy

FROM ${BASE_IMAGE} AS common

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

LABEL maintainer="carlo.mancini-terracciano@uniroma1.it"

ARG G4_VERSION
ARG BUILD_DATE

LABEL org.label-schema.geant4-version="${G4_VERSION}"
LABEL org.label-schema.build-date="${BUILD_DATE}"
LABEL org.label-schema.name="carlomt/geant4"
LABEL org.label-schema.description="Geant4 Docker image"
LABEL org.label-schema.url="https://github.com/carlomt/docker-geant4"
LABEL org.label-schema.docker.cmd="docker build -t carlomt/geant4:latest --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --no-cache=true ."

ENV CC=/usr/bin/gcc
ENV CXX=/usr/bin/g++

ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Basic tools needed to add external APT repositories
RUN apt-get update && \
    apt-get -yq --no-install-recommends install \
        ca-certificates \
        gpg \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Add Kitware APT repository.
# The temporary key is used only to install kitware-archive-keyring,
# which then manages future Kitware repository keys.
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
    | gpg --dearmor - \
    | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main" \
        > /etc/apt/sources.list.d/kitware.list && \
    apt-get update && \
    rm -f /usr/share/keyrings/kitware-archive-keyring.gpg && \
    apt-get -yq --no-install-recommends install \
        kitware-archive-keyring && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY ./packages /tmp/packages

RUN apt-get update && \
    apt-get -yq --no-install-recommends install \
        $(grep -vE '^\s*(#|$)' /tmp/packages) && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /tmp/packages /var/lib/apt/lists/* /var/cache/apt/archives/*

#######################################################################

FROM common AS builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN mkdir -p /tmp/geant4/build /opt/geant4 && \
    wget -O /tmp/geant4.tar.gz \
        "https://geant4-data.web.cern.ch/geant4-data/releases/source/geant4-v${G4_VERSION}.tar.gz" && \
    tar xf /tmp/geant4.tar.gz -C /tmp/geant4/ && \
    mv "/tmp/geant4/geant4-v${G4_VERSION}" /tmp/geant4/src && \
    cmake -S /tmp/geant4/src -B /tmp/geant4/build \
        -G Ninja \
        -DCMAKE_INSTALL_PREFIX=/opt/geant4 \
        -DGEANT4_INSTALL_DATA=OFF \
        -DGEANT4_INSTALL_DATADIR=/g4data \
        -DGEANT4_BUILD_MULTITHREADED=ON \
        -DGEANT4_USE_GDML=ON \
        -DGEANT4_USE_QT=OFF \
        -DGEANT4_USE_OPENGL_X11=OFF \
        -DGEANT4_INSTALL_EXAMPLES=OFF && \
    cmake --build /tmp/geant4/build --target install --parallel && \
    rm -rf /tmp/geant4 /tmp/geant4.tar.gz

#######################################################################

FROM common

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --from=builder /opt/geant4/ /opt/geant4/

RUN mkdir -p /g4data && \
    chmod 777 /g4data && \
    ln -s /g4data /opt/geant4/data

COPY ./bashrc.sh /opt/bashrc.sh

RUN chmod +x /opt/bashrc.sh

ENTRYPOINT ["/opt/bashrc.sh"]

WORKDIR /workspace

CMD ["bash"]