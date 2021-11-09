#! /bin/bash

# Path to environment directory created using python virtualenv
mkdir ~/cosim2_env
export env_path=~/cosim2_env
# Path to clone into:
mkdir ${env_path}/sources
export src_path=${env_path}/sources
# Software versions:
export HELICS_BRANCH=v2.8.0
#export GLD_BRANCH=7d2931eeb4c22520328cb02bad8dca1f13b74bb1 # Tip of develop as of 2021-05-07
export GLD_BRANCH=107009aa8d94c1dc571e992849d4028474fde805 # Tip of develop as of 2021-10-23
export NS3_BRANCH=ns-3.35
export HELICS_NS3_BRANCH=3d494d19fc7eb13c1dcbd6f57645bbf8a94d3c0a # Tip of main as of 2021-11-2

# Where to put our built software?
export HELICS_INSTALL_PATH=${env_path} #~/cosim/venv3
export GLD_INSTALL_PATH=${env_path} #~/cosim/venv3

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
export PATH=${PATH}:${env_path}/bin

#apt-get update && apt-get install -y \
#  autoconf \
#  automake \
#  build-essential \
#  cmake \
#  g++ \
#  gcc \
#  git \
#  libboost-dev \
#  libboost-filesystem-dev \
#  libboost-program-options-dev \
#  libboost-test-dev \
#  libtool \
#  libzmq5-dev \
#  make \
#  python3.9 \
#  python3.9-dev \
#  python3-pyqt5 \
#  swig \
#  mercurial \
#  qt5-default

# (Shallowly) clone HELICS.
git clone https://github.com/GMLC-TDC/HELICS.git \
  --branch ${HELICS_BRANCH} --depth 1 --single-branch ${src_path}/helics${HELICS_BRANCH}

  # Follow HELICS template and work in an empty building directory.
cd ${src_path}/helics${HELICS_BRANCH}
mkdir build
cd build

  # Run cmake
cmake \
  -DBUILD_PYTHON_INTERFACE=ON \
  -DPYTHON_INCLUDE_DIR=/usr/include/python3.9/ \
  -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.9.so \
  -DCMAKE_INSTALL_PREFIX=${HELICS_INSTALL_PATH} \
  -DHELICS_BUILD_CXX_SHARED_LIB=ON \
  ..
  # HARD-CODE Python paths.

  # Make and install.
make -j8 && make -j8 install


# Build GridLAB-D (and its dependency, Xerces)

mkdir ${src_path}/gridlab-d
cd ${src_path}/gridlab-d

# Shallowly clone the repository. Special sequence of commands in order
# to only fetch the state of the repo at a single sha.
# https://stackoverflow.com/a/43136160/11052174
git init && \
  git remote add origin https://github.com/gridlab-d/gridlab-d.git && \
  git fetch --depth 1 origin ${GLD_BRANCH} && \
  git checkout FETCH_HEAD

# Install Xerces.
cd ${src_path}/gridlab-d/third_party
perl -E "print '*' x 80" && \
  printf '\nInstalling Xerces...\n' && \
  tar -xzf xerces-c-3.2.0.tar.gz && \
  cd ${src_path}/gridlab-d/third_party/xerces-c-3.2.0 && \
  ./configure --prefix=${GLD_INSTALL_PATH} --disable-static CFLAGS=-O2 CXXFLAGS=-O2 && \
  make -j $(($(nproc) + 1)) && \
  make -j $(($(nproc) + 1)) install

# Install GridLAB-D
cd ${src_path}/gridlab-d
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
cd ${src_path}
# (Shallowly) clone NS-3
git clone https://gitlab.com/nsnam/ns-3-dev.git \
  --branch ${NS3_BRANCH} --depth 1 --single-branch ${src_path}/ns-3-dev-${NS3_BRANCH}
cd ${src_path}/ns-3-dev-${NS3_BRANCH}
# (Shallowly) clone helics-ns3
#git clone https://github.com/GMLC-TDC/helics-ns3.git \
#  --branch ${HELICS_NS3_BRANCH} --depth 1 --single-branch contrib/helics

# Shallowly clone the repository. Special sequence of commands in order
# to only fetch the state of the repo at a single sha.
# https://stackoverflow.com/a/43136160/11052174
mkdir contrib/helics
cd contrib/helics

git init && \
  git remote add origin https://github.com/GMLC-TDC/helics-ns3.git && \
  git fetch --depth 1 origin ${HELICS_NS3_BRANCH} && \
  git checkout FETCH_HEAD
 
cd ${src_path}/ns-3-dev-${NS3_BRANCH}
./waf configure --prefix=${HELICS_INSTALL_PATH} --with-helics=${HELICS_INSTALL_PATH} --disable-werror --enable-examples --enable-tests
./waf build
./waf install
# Install NetAnim
#cd /
#hg clone http://code.nsnam.org/netanim
#cd netanim
#make clean
#qmake NetAnim.pro
#make

