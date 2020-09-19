#!/usr/bin/env bash


mkdir -p downloads/mesh_files
cd downloads/mesh_files/

# Remove previous downloads to save space
rm d20*
rm current_mesh

myyear=`date +'%Y'`
wget ftp://nlmpubs.nlm.nih.gov/online/mesh/MESH_FILES/asciimesh/d20*.bin

# Link to download
ln -s d20* current_mesh
