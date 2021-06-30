#! /bin/bash
apt-get update && apt-get install -y \
  mercurial \
  qt5-default
# Install NetAnim
cd /
hg clone http://code.nsnam.org/netanim
cd netanim
make clean
qmake NetAnim.pro
make
