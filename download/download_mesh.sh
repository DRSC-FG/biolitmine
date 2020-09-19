#!/usr/bin/env bash

# download mesh files from

mkdir -p downloads/mesh_files
cd downloads/mesh_files/

#remove previous downloads
rm d20*
rm current_mesh

#wget ftp://nlmpubs.nlm.nih.gov/online/mesh/2019/asciimesh/d20*.bin
myyear=`date +'%Y'`
wget ftp://nlmpubs.nlm.nih.gov/online/mesh/MESH_FILES/asciimesh/d20*.bin

# Link to download

ln -s d20* current_mesh
