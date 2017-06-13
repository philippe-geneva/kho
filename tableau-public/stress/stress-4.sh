#!/bin/bash

HOST=hqsudevlin.who.int
PORT=8086
APP=tableau-public
HITS=1000


#
# Stress test the frame function
#
#
URL="http://${HOST}:${PORT}/${APP}/tpc-frame.jsp?id=300"

count=0;
while [ ${count} -lt ${HITS} ]; do
  count=$((${count} + 1))
  echo ${count} 
  wget -O /dev/null --quiet ${URL}
done
