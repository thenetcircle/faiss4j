# faiss4j
java wrapper for facebook faiss

swig -c++ -java -package com.thenetcircle.services.faiss -o ../../swig_faiss.cpp -outdir ../../output -I../ swigfaiss.swig

#
g++ -std=c++11 \
 -fPIC \
 -fopenmp \
 -m64 \
 -Wno-sign-compare \
 -g \
 -O3 \
 -Werror \
 -Wextra \
 -msse4 \
 -mpopcnt  \
 -z noexecstack \
 -L /usr/local/lib \
 -I ../faiss-1.5.0/ \
 -I /usr/lib/jvm/java-1.8.0-openjdk/include/ \
 -I /usr/lib/jvm/java-1.8.0-openjdk/include/linux/ \
 -lfaiss \
  swigfaiss4j.cpp \
  -shared -o swigfaiss4j.so
  
#
libfaiss.so should be in current path
  
LD_LIBRARY_PATH=. mvn test -Dtest=com.thenetcircle.services.faiss4j.tests.Examples#testLib  