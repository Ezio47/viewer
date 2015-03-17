#!/bin/sh

echo Hi.

#echo $SHELL

set -a

PATH=/usr/local/bin:$PATH
OSSIM_INSTALL_PREFIX=/Users/mgerlek/work/dev/build/ossim
OSSIM_PREFS_FILE=/Users/mgerlek/.ossimrc
OSSIM_DEV_HOME=/Users/mgerlek/work/dev/ossim
DYLD_FRAMEWORK_PATH=/Users/mgerlek/work/dev/build/ossim/Frameworks:
DYLD_LIBRARY_PATH=/Users/mgerlek/work/dev/build/pdal/lib:/Users/mgerlek/work/dev/build/pcl/lib:/Users/mgerlek/work/dev/build/nitro/lib:

#printenv

$@

echo Bye.
