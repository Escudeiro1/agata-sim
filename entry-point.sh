#!/bin/bash
set -e
source /usr/cernroot/root/bin/thisroot.sh
source /usr/gS/bin/Gw-env.sh
source /usr/local/geant4.10.05.p01/build/geant4make.sh
export G4AGATAVACUUMINWORLD=yes
export MINPROBSING=0.015
exec "$@"
