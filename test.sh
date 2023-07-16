#!/bin/bash
input="test/tests.t"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
while read -r line
do

  if v run . -c  "test/$line" > /dev/null 2>&1; then
   echo -e "TEST test/$line ${GREEN}[OK]${NC}"
  else
   echo -e "TEST test/$line ${RED}[FAIL]${NC}"
  fi
done < "$input"