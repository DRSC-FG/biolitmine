#!/usr/bin/env bash


echo "starting $1 - $2"

Rscript rscripts/$1Extraction.R $2 $3 $4

echo "done $1 - $2"

