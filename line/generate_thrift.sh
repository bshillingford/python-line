#!/bin/sh

# This file is NOT part of a Makefile or standard build process because:
#   1. The thrift interface spec will be unlikely to change.
#   2. This requires Apache Thrift (not just python-thrift) to be installed.

echo Thrift is installed at:
which thrift
echo 

mkdir linethrift
echo Starting Thrift.
thrift -out linethrift --gen py:new_style line.thrift
echo Thrift return code: $?

echo Fixing directory structure of output...
rm linethrift/__init__.py
mv linethrift/linethrift/*.py linethrift/
rm linethrift/linethrift/Line-remote
rmdir linethrift/linethrift/
echo Done.

