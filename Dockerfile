FROM ubuntu:18.04

ENV LANG=C.UTF-8

RUN apt-get update \
 && apt-get -y install git \
 && apt-get -y install python \
 && apt-get -y install wget 

RUN mkdir /usr/cernroot
WORKDIR /usr/cernroot

RUN wget https://root.cern/download/root_v6.18.04.source.tar.gz
RUN tar -xvzf root_v6.18.04.source.tar.gz root-6.18.04/
RUN apt-get install -y git dpkg-dev cmake g++ gcc binutils libx11-dev libxpm-dev libxft-dev libxext-dev
RUN apt-get install -y gfortran libssl-dev libpcre3-dev xlibmesa-glu-dev libglew1.5-dev libftgl-dev libmysqlclient-dev libfftw3-dev libcfitsio-dev graphviz-dev libavahi-compat-libdnssd-dev libldap2-dev python-dev libxml2-dev libkrb5-dev libgsl0-dev libqt4-dev
RUN mkdir /usr/cernroot/root
WORKDIR /usr/cernroot/root
RUN cmake ../root-6.18.04/ -Dall=ON -Dbuiltin_xrootd=ON -Dcuda=OFF -Dtmva-gpu=OFF
RUN cmake --build . -- -j7
RUN mkdir /usr/gS/
WORKDIR /usr/gS/
RUN git clone https://gitlab.in2p3.fr/IPNL_GAMMA/scripts.git
RUN /bin/bash -c "source /usr/cernroot/root/bin/thisroot.sh;python scripts/gRaySoftware.py --gw= all"
RUN /bin/bash -c "source /usr/gS/bin/Gw-env.sh"

RUN git clone https://github.com/wkentaro/gdown.git && apt install -y python3-pip
WORKDIR /usr/local/gdown
RUN pip3 install gdown

WORKDIR /usr/local
RUN gdown https://drive.google.com/uc?id=1Wid1CH38KVaM1nro4YHsVIZb5RLaGOIb && tar -xvf geant4.10.05.p01.tar.gz && rm -f geant4.10.05.p01.tar.gz && gdown https://drive.google.com/uc?id=1nGf9gYdt32SpAVEwTAeWNaxGwILBNLAf && tar -xzvf Agata.tar.gz && rm -f Agata.tar.gz && mv opt agata
WORKDIR /usr/local/geant4.10.05.p01
RUN mkdir build
WORKDIR /usr/local/geant4.10.05.p01/build

RUN apt install -y libxerces-c-dev && rm -rf * && apt install -y libxmu-dev/bionic libmotif-dev
RUN cmake -DGEANT4_BUILD_CXXSTD=c++11 -DGEANT4_INSTALL_DATA=ON -DGEANT4_USE_GDML=ON -DGEANT4_USE_QT=ON -DGEANT4_USE_XM=ON -DGEANT4_USE_OPENGL_X11=ON -DGEANT4_USE_RAYTRACER_X11=ON -L${libdir} -lxerces-c -I${includedir} -DCMAKE_INSTALL_PREFIX=/usr/local/geant4.10.05.p01/build /usr/local/geant4.10.05.p01
RUN make -j10
RUN make install
ENV GEANTDIST=/usr/local/geant4.10.05.p01
ENV G4WORKDIR=/usr/local/geant4.10.05.p01
ENV CMAKE_PREFIX_PATH=$GEANTDIST/build/lib/geant4.10.05.p01:$CMAKE_PREFIX_PATH

#Aza Galo Veio
ENV DYLD_LIBRARY_PATH=/usr/cernroot/root/lib:/usr/gS/lib
ENV ROOTSYS=/usr/cernroot/root
ENV CMAKE_PREFIX_PATH=/usr/cernroot/root:/usr/local/geant4.10.05.p01/build/lib/geant4.10.05.p01:
ENV JUPYTER_PATH=/usr/cernroot/root/etc/notebook
ENV SHLIB_PATH=/usr/cernroot/root/lib:/usr/gS/lib
ENV GWSYS=/usr/gS
ENV LIBPATH=/usr/cernroot/root/lib:/usr/gS/lib
ENV GEANTDIST=/usr/local/geant4.10.05.p01
ENV TERM=xterm
ENV SHLVL=1
ENV PYTHONPATH=/usr/cernroot/root/lib
ENV MANPATH=/usr/cernroot/root/man:/usr/local/man:/usr/local/share/man:/usr/share/man
ENV PATH=/usr/gS/bin:/usr/cernroot/root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV CLING_STANDARD_PCH=none

RUN /bin/bash -c "source /usr/local/geant4.10.05.p01/build/share/Geant4-10.5.1/geant4make/geant4make.sh; cmake -DGeant4_DIR=/usr/local/geant4.10.05.p01/build/lib/geant4.10.05.p01 ../; make"
ENTRYPOINT ["/dck/entry-point.sh"]

WORKDIR /usr/local
RUN gdown https://drive.google.com/uc?id=1nGf9gYdt32SpAVEwTAeWNaxGwILBNLAf && tar -xzvf Agata.tar.gz && rm -f Agata.tar.gz && mv opt agata
ENV CMAKE_PREFIX_PATH=$GEANTDIST/build/lib/Geant4-10.5.1:$CMAKE_PREFIX_PATH
WORKDIR /usr/local/agata/AgataSimulation/branches/GANIL/trunk
RUN mkdir build
RUN /bin/bash -c  "source /usr/local/geant4.10.05.p01/build/geant4make.sh"
WORKDIR /usr/local/agata/AgataSimulation/branches/GANIL/trunk/build
RUN cmake ../
RUN make -j10
ENV PATH=/usr/local/agata/AgataSimulation/branches/GANIL/trunk/build:$PATH


######################################
RUN ln -s /usr/progs/bin/stopx && ln -s /usr/progs/bin/adac && ln -s /usr/progs/bin/ccf && ln -s /usr/progs/bin/charge && ln -s /usr/progs/bin/chil && ln -s /usr/progs/bin/damm && ln -s /usr/progs/bin/funkyfit && ln -s /usr/progs/bin/kineq && ln -s /usr/progs/bin/lemo && ln -s /usr/progs/bin/scanu && ln -s /usr/progs/bin/scanlnk && ln -s /usr/progs/bin/lemolnk && ln -s /usr/progs/bin/lemo.hep && ln -s /usr/progs/bin/scan.hep && ln -s /usr/progs/bin/stopx.hep && ln -s /usr/progs/bin/funkyfit.hep && ln -s /usr/progs/bin/damm.hep && ln -s /usr/progs/bin/laser.init
WORKDIR /usr/local
RUN git clone https://github.com/Escudeiro1/GASPware-1.git
WORKDIR /usr/local/bin
RUN chmod +x /usr/local/GASPware-1/bin/xtrackn && chmod +x /usr/local/GASPware-1/bin/cmat && chmod +x /usr/local/GASPware-1/bin/gsort && chmod +x /usr/local/GASPware-1/bin/list_tape && chmod +x /usr/local/GASPware-1/bin/mat_stop && chmod +x /usr/local/GASPware-1/bin/recal_cob && chmod +x /usr/local/GASPware-1/bin/recal_corr && chmod +x /usr/local/GASPware-1/bin/recal_diff && chmod +x /usr/local/GASPware-1/bin/recal_doppl && chmod +x /usr/local/GASPware-1/bin/recal_gain && chmod +x /usr/local/GASPware-1/bin/recal_test && chmod +x /usr/local/GASPware-1/bin/recal_time && chmod +x /usr/local/GASPware-1/bin/sadd && chmod +x /usr/local/GASPware-1/bin/stopp && chmod +x /usr/local/GASPware-1/bin/tapetotape && ln -s /usr/local/GASPware-1/bin/xtrackn && ln -s /usr/local/GASPware-1/bin/cmat && ln -s /usr/local/GASPware-1/bin/gsort && ln -s /usr/local/GASPware-1/bin/list_tape && ln -s /usr/local/GASPware-1/bin/mat_stop && ln -s /usr/local/GASPware-1/bin/recal_cob && ln -s /usr/local/GASPware-1/bin/recal_corr && ln -s /usr/local/GASPware-1/bin/recal_diff && ln -s /usr/local/GASPware-1/bin/recal_doppl && ln -s /usr/local/GASPware-1/bin/recal_gain && ln -s /usr/local/GASPware-1/bin/recal_test && ln -s /usr/local/GASPware-1/bin/recal_time && ln -s /usr/local/GASPware-1/bin/sadd && ln -s /usr/local/GASPware-1/bin/stopp && ln -s /usr/local/GASPware-1/bin/tapetotape

WORKDIR /usr/local
RUN git clone https://github.com/Escudeiro1/rw05.git
WORKDIR /usr/local/rw05/bin
RUN chmod +x *

WORKDIR /usr/local/bin
RUN mv /usr/local/rw05/bin/* .

WORKDIR /usr/local
RUN git clone https://github.com/wkentaro/gdown.git && apt install -y python3-pip
WORKDIR /usr/local/gdown
RUN pip3 install gdown
WORKDIR /usr/local/
RUN mkdir fontgls
WORKDIR /usr/local/fontgls
RUN gdown https://drive.google.com/uc?id=1PfOTPuF4U8a7_WK223nEtTA8SSEddW2o && tar -xzvf fonts.tar.gz && cp -n -r /usr/local/fontgls/fonts/truetype /usr/share/fonts/truetype && cp -n -r /usr/local/fontgls/fonts/type1 /usr/share/fonts/type1 && cp -n -r /usr/local/fontgls/fonts/X11 /usr/share/fonts/X11 
WORKDIR /usr/share/poppler/cMap/Adobe-Japan1
RUN cp -n /usr/local/fontgls/fonts/cmap/adobe-japan1/* .
WORKDIR /usr/share/poppler/cMap/Adobe-Japan2
RUN cp -n /usr/local/fontgls/fonts/cmap/adobe-japan2/* . && cp -n -r /usr/local/fontgls/fonts/cmap/gs-cjk-resource /usr/share/fonts/cmap
WORKDIR /usr/local

RUN DEBIAN_FRONTEND=noninteractive apt install -y fontforge-common fontforge-nox fonts-ancient-scripts fonts-cantarell fonts-inconsolata fonts-lmodern fonts-symbola fonts-thai-tlwg fonts-tlwg-garuda fonts-tlwg-garuda-ttf fonts-tlwg-kinnari fonts-tlwg-kinnari-ttf fonts-tlwg-laksaman fonts-tlwg-laksaman-ttf fonts-tlwg-loma fonts-tlwg-loma-ttf fonts-tlwg-mono fonts-tlwg-mono-ttf fonts-tlwg-norasi fonts-tlwg-norasi-ttf fonts-tlwg-purisa fonts-tlwg-purisa-ttf fonts-tlwg-sawasdee fonts-tlwg-sawasdee-ttf fonts-tlwg-typewriter fonts-tlwg-typewriter-ttf fonts-tlwg-typist fonts-tlwg-typist-ttf fonts-tlwg-typo fonts-tlwg-typo-ttf fonts-tlwg-umpush fonts-tlwg-umpush-ttf fonts-tlwg-waree fonts-tlwg-waree-ttf gsfonts html2ps imagemagick-6-common libimage-magick-perl libimage-magick-q16-perl liblqr-1-0  libptexenc1 libqt5designer5 libqt5help5 libqt5sql5 libqt5sql5-sqlite libqt5test5 libqt5xml5 libsys-cpu-perl libtexluajit2 libtk8.6 libttfautohint1 libuninameslist1 libzzip-0-13 lmodern pcf2bdf perlmagick python3-libxml2 python3-pyqt5 python3-sip t1-xfree86-nonfree t1utils tcl tex-common texlive-base texlive-binaries texlive-latex-base tipa tk tk8.6 toilet toilet-fonts treeline trscripts ttf-aenigma ttf-ancient-fonts ttf-ancient-fonts-symbola ttf-anonymous-pro ttf-bitstream-vera ttf-denemo ttf-engadget ttf-sjfonts ttf-staypuft ttf-summersby ttf-tagbanwa ttf-ubuntu-font-family ttf-unifont ttf-xfree86-nonfree ttf-xfree86-nonfree-syriac ttf2ufm tv-fonts xfonts-100dpi-transcoded xfonts-75dpi-transcoded xfonts-biznet-100dpi xfonts-biznet-75dpi xfonts-biznet-base xfonts-efont-unicode xfonts-efont-unicode-ib xfonts-intl-european xfonts-intl-phonetic xfonts-mona xfonts-mplus xfonts-nexus xfonts-shinonome xfonts-terminus xfonts-terminus-dos xfonts-terminus-oblique xfonts-thai xfonts-thai-etl xfonts-thai-manop xfonts-thai-nectec xfonts-thai-poonlap xfonts-thai-vor xfonts-tipa xfonts-traditional xfonts-unifont xfonts-wqy xfonts-x3270-misc xfstt xgridfit xhtml2ps xorgxrdp xsltproc xfonts-100dpi xfonts-75dpi
###############
RUN apt install -y cmake pkg-config mesa-utils libglu1-mesa-dev freeglut3-dev mesa-common-dev libglew-dev libglfw3-dev libglm-dev libao-dev libmpg123-dev
###############
#RUN apt install -y xlsfonts
###############
WORKDIR /app
#WORKDIR /usr/local
#RUN mkdir gdml && cd gdml && git init && git remote add gdml-files/AGATA https://github.com/malabi/gdml-files && git fetch gdml-files/AGATA && git checkout gdml-files/AGATA/master -- AGATA && git remote add gdml-files/GALILEO https://github.com/malabi/gdml-files && git fetch gdml-files/GALILEO && git checkout gdml-files/GALILEO/master -- GALILEO && mkdir agata && cd agata
#RUN apt install -y subversion
#WORKDIR /usr/local/agata


#WORKDIR /usr/local/agata/AgataSimulation/branches/GANIL/trunk_old
#RUN mkdir build
#WORKDIR /usr/local/agata/AgataSimulation/branches/GANIL/trunk_old/build

