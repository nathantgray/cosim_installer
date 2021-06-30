#! /bin/bash
mkdir /usr/local/python
export HELICS_BRANCH=v2.7.0
# Tip of develop as of 2021-05-07
export GLD_BRANCH=7d2931eeb4c22520328cb02bad8dca1f13b74bb1

# Where to put our built software?
export HELICS_INSTALL_PATH=/usr/local
export GLD_INSTALL_PATH=/usr/local

# Patch the Python path so it can find helics.py.
export PYTHONPATH=${HELICS_INSTALL_PATH}/python

# GridLAB-D required environment variables:
export CXXFLAGS=-I${GLD_INSTALL_PATH}/share/gridlabd \
    GLPATH=${GLD_INSTALL_PATH}/lib/gridlabd:${GLD_INSTALL_PATH}/share/gridlabd \
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${HELICS_INSTALL_PATH}/lib
    # No need to patch the path when using standard /usr/local location.
    # PATH=${PATH}:/usr/local/bin \
    # (Maybe) need to update the LD_LIBRARY_PATH so GridLAB-D can find
    # the HELICS libraries.
# add-apt-repository ppa:deadsnakes/ppa
apt-get update && apt-get install -y \
  autoconf \
  automake \
  build-essential \
  cmake \
  g++ \
  gcc \
  git \
  libboost-dev \
  libboost-filesystem-dev \
  libboost-program-options-dev \
  libboost-test-dev \
  libtool \
  libzmq5-dev \
  make \
  python3.7 \
  python3.7-dev \
  python3-pyqt5 \
  swig \
  mercurial \
  qt5-default

# (Shallowly) clone HELICS.
git clone https://github.com/GMLC-TDC/HELICS.git \
  --branch ${HELICS_BRANCH} --depth 1 --single-branch /tmp/helics

  # Follow HELICS template and work in an empty building directory.
cd /tmp/helics/
mkdir build
cd build

  # Run cmake
cmake \
  -DBUILD_PYTHON_INTERFACE=ON \
  -DPYTHON_INCLUDE_DIR=/usr/include/python3.7/ \
  -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.7m.so \
  -DCMAKE_INSTALL_PREFIX=${HELICS_INSTALL_PATH} \
  -DHELICS_BUILD_CXX_SHARED_LIB=ON \
  ..
  # HARD-CODE Python paths.

  # Make and install.
  # WORKDIR /tmp/helics
make -j8 && make -j8 install


# Build GridLAB-D (and its dependency, Xerces)
cd /
mkdir /tmp/gridlab-d
cd /tmp/gridlab-d

# Shallowly clone the repository. Special sequence of commands in order
# to only fetch the state of the repo at a single sha.
# https://stackoverflow.com/a/43136160/11052174
git init && \
  git remote add origin https://github.com/gridlab-d/gridlab-d.git && \
  git fetch --depth 1 origin ${GLD_BRANCH} && \
  git checkout FETCH_HEAD

# Install Xerces.
cd /
cd /tmp/gridlab-d/third_party
perl -E "print '*' x 80" && \
  printf '\nInstalling Xerces...\n' && \
  tar -xzf xerces-c-3.2.0.tar.gz && \
  cd /tmp/gridlab-d/third_party/xerces-c-3.2.0 && \
  ./configure --prefix=${GLD_INSTALL_PATH} --disable-static CFLAGS=-O2 CXXFLAGS=-O2 && \
  make -j $(($(nproc) + 1)) && \
  make -j $(($(nproc) + 1)) install

# Install GridLAB-D
cd /
cd /tmp/gridlab-d
perl -E "print '*' x 80" && \
  printf '\nInstalling GridLAB-D...\n' && \
  autoreconf -isf && \
  ./configure --prefix=${GLD_INSTALL_PATH} --with-helics=${HELICS_INSTALL_PATH} --with-xerces=${GLD_INSTALL_PATH} --enable-silent-rules 'CFLAGS=-g -O2 -w' 'CCFLAGS=-g -O2 -w' 'CXXFLAGS=-g -O2 -w -std=c++14' 'LDFLAGS=-g -O2 -w' && \
  make -j $(($(nproc) + 1)) && \
  make -j $(($(nproc) + 1)) install && \
  perl -E "print '*' x 80" && \
  printf "\nWe're all done building!\n"
  # http://gridlab-d.shoutwiki.com/wiki/Builds
  # http://gridlab-d.shoutwiki.com/wiki/Connection:helics_msg

# Install NS-3
cd /
git clone https://gitlab.com/nsnam/ns-3-dev.git /home/cosim/ns-3-dev
cd /home/cosim/ns-3-dev
git clone https://github.com/GMLC-TDC/helics-ns3 contrib/helics
./waf configure --prefix=${HELICS_INSTALL_PATH} --with-helics=${HELICS_INSTALL_PATH} --disable-werror --enable-examples --enable-tests
./waf build

# Install NetAnim
cd /
hg clone http://code.nsnam.org/netanim
cd netanim
make clean
qmake NetAnim.pro
make
