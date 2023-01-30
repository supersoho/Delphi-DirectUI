#!/bin/bash

echo "Deleting ugly files..."

ROOTDIR=".."
EXTS="*.dcu *.ppu *.a *.dpu *.o *.rst *.bak *.bk? *.~* *.*~ *.or *.obj"
EXTS=$EXTS" *.tgs *.tgw *.identcache *.local"

delindir()
{
  pushd $1 1>/dev/null
  echo "Processing dir: $1" 
  rm -f `ls $EXTS 2>/dev/null `
  popd 1>/dev/null
}

delintree()
{
  echo "Processing dir tree: $1" 
  for EXT in $EXTS; do 
    find $1 -name "$EXT" -exec rm -f {} \; 
  done  
}

delintree $ROOTDIR/Bin
delintree $ROOTDIR/Demos 
delintree $ROOTDIR/Scripts 
delintree $ROOTDIR/Source/Wrappers
delintree $ROOTDIR/Source/JpegLib
delintree $ROOTDIR/Source/ZLib
delintree $ROOTDIR/Source/Extensions
delintree $ROOTDIR/Source/Projects
delindir $ROOTDIR/Source
delindir $ROOTDIR/Extras/Extensions
delintree $ROOTDIR/Extras/Demos
delintree $ROOTDIR/Extras/Tools

echo "Clean finished"
