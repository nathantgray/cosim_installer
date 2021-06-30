#! /bin/bash
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

cd /
git clone https://gitlab.com/nsnam/ns-3-dev.git
cd ns-3-dev
git clone https://github.com/GMLC-TDC/helics-ns3 contrib/helics
./waf configure --prefix=${HELICS_INSTALL_PATH} --with-helics=${HELICS_INSTALL_PATH} --disable-werror --enable-examples --enable-tests
./waf build
