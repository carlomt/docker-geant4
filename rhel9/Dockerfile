FROM redhat/ubi9:9.4 as common
LABEL maintainer="carlo.mancini-terracciano@uniroma1.it"

ARG G4_VERSION
ARG XERCES_VERSION=3.2.5

#labels
LABEL org.label-schema.geant4-version=$G4_VERSION
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="carlomt/geant4"
LABEL org.label-schema.description="Geant4 Docker image"
LABEL org.label-schema.url="https://github.com/carlomt/docker-geant4"
LABEL org.label-schema.docker.cmd="docker build -t carlomt/geant4:latest --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --no-cache=true ."

ENV CC=/usr/bin/gcc
ENV CXX=/usr/bin/g++

# Install necessary build tools
RUN dnf install -y \
    cmake \
    expat expat-devel \
    gcc \
    gcc-c++ \
    ninja-build \
    which \
    tar \
    make \
    && dnf clean all

# Download, build, and install Xerces-C from source
RUN curl -L https://downloads.apache.org/xerces/c/3/sources/xerces-c-${XERCES_VERSION}.tar.gz \
    -o xerces-c.tar.gz && \
    tar -xzf xerces-c.tar.gz && \
    cd xerces-c-${XERCES_VERSION} && \
    mkdir build && cd build && \
    cmake -G Ninja .. && \
    ninja install && \
    cd ../.. && \
    rm -rf xerces-c-${XERCES_VERSION} xerces-c.tar.gz

#######################################################################

FROM common AS builder

RUN mkdir -p /tmp/geant4/build && \
    mkdir -p /opt/geant4/ && \
    curl https://geant4-data.web.cern.ch/geant4-data/releases/source/geant4-v${G4_VERSION}.tar.gz \
    --output /tmp/geant4.tar.gz &&\    
    tar xf /tmp/geant4.tar.gz -C /tmp/geant4/ && \
    mv /tmp/geant4/geant4-v${G4_VERSION}/ /tmp/geant4/src/ && \
    cd /tmp/geant4/build && \
    cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/opt/geant4 \
    -DGEANT4_INSTALL_DATA=OFF \
    -DGEANT4_INSTALL_DATADIR=/opt/geant4/data \
    -DGEANT4_BUILD_MULTITHREADED=ON \
    -DGEANT4_USE_GDML=ON \
    -DGEANT4_USE_QT=OFF \
    -DGEANT4_USE_OPENGL_X11=OFF \
    -DGEANT4_INSTALL_EXAMPLES=OFF \
    ../src/ && \
    ninja install
    
#######################################################################

FROM common

COPY --from=builder /opt/geant4/ /opt/geant4/

RUN mkdir -p /opt/geant4/data && chmod 777 /opt/geant4/data

# Set the entrypoint script to set Geant4 environment variables
COPY bashrc.sh /opt/bashrc.sh
RUN chmod +x /opt/bashrc.sh
ENTRYPOINT ["/opt/bashrc.sh"]

WORKDIR /workspace

# Default command to execute if none is provided to docker run
CMD ["bash"]