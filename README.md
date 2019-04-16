# faiss4j
java wrapper for [facebook faiss](https://github.com/facebookresearch/faiss)

how to build this

#build faiss first

Firstly we need to compile from faiss code, please follow [this doc](https://github.com/facebookresearch/faiss/blob/master/INSTALL.md)

I started the experiment with a clean centos docker image, so I needed to install something beforehand

```bash
yum install -y epel-release
yum install -y git
yum install -y devtoolset-8.x86_64
yum install -y gcc.x86_64 gcc-c++.x86_64 libgcc.x86_64
yum install -y cmake3.x86_64 make
yum install -y swig3.x86_64
yum install -y java-1.8.0-openjdk-devel.x86_64
yum install -y maven.noarch
yum install -y python-devel.x86_64
yum install -y python34-devel
yum install -y blas64.x86_64 blas64-devel.x86_64 blas64-static.x86_64
yum install -y lapack64.x86_64 lapack64-devel.x86_64 lapack64-static.x86_64
```

can't do GPU building since I don't have gpu on the server.

enter faiss, run ./configure to check environment
```bash
./configure --without-cuda
make
make install
```
it shows
```bash 
/usr/bin/mkdir -p /usr/local/lib /usr/local/include/faiss
cp libfaiss.a libfaiss.so /usr/local/lib
```
then faiss is built

#build java wrapper
in root of faiss4j 
I chose [faiss tagged 1.5.0](https://github.com/facebookresearch/faiss/archive/v1.5.0.zip)
*IT MIGHT NOT WORK WITH OTHER VERSIONS*
```bash
swig -c++ -java -package com.thenetcircle.services.faiss -o swigfaiss4j.cpp  -outdir src/main/java/com/thenetcircle/services/faiss/ -Doverride= -I../faiss-1.5.0/ swigfaiss4j.swig
```
this command uses swig to generate a cpp file swigfaiss4j.cpp
which works as bridge between jni and faiss code,
it also creates correspondent java definitions 

now we need to compile this swigfaiss4j.cpp into lib for java to call,
(I am just a java guy with little knowledge with compiling c/c++)

```bash
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
```  

at last, libfaiss.so should be in current path
-rwxr-xr-x 1 root root 3594624 Apr 16 09:20 swigfaiss4j.so
  
then let us run some test
```bash
LD_LIBRARY_PATH=. mvn test -Dtest=com.thenetcircle.services.faiss4j.tests.Examples#testLib  
```

