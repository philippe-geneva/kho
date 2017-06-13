#!/bin/bash

HOST=hqsudevlin.who.int
PORT=8086
APP=cabinet
HITS=1000

URL="http://${HOST}:${PORT}/${APP}/uhc.jsp?id=1"

count=0;
while [ ${count} -lt ${HITS} ]; do
  count=$((${count} + 1))
  echo ${count} 
  wget -O /dev/null --quiet ${URL}
done
