/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD+Patents license found in the
 * LICENSE file in the root directory of this source tree.
 */

// -*- C++ -*-

// This file describes the C++-scripting language bridge for both Lua
// and Python It contains mainly includes and a few macros. There are
// 3 preprocessor macros of interest:
// GPU_WRAPPER: also compile interfaces for GPU.

#ifdef SWIGJAVA
%include "arrays_java.i"
//%apply int[] {int *};
//%apply double[] {double *};
//%apply float[] {float *};
//%apply long[] {long *};
%include "carrays.i"
%array_class(int, intArray);
%array_class(float, floatArray);
%array_class(long, longArray);
%array_class(double, doubleArray);
#endif

#ifdef GPU_WRAPPER
%module swigfaiss_gpu;
#else
%module swigfaiss;
#endif

// fbode SWIG fails on warnings, so make them non fatal
#pragma SWIG nowarn=321
#pragma SWIG nowarn=403
#pragma SWIG nowarn=325
#pragma SWIG nowarn=389
#pragma SWIG nowarn=341

typedef unsigned long uint64_t;
typedef uint64_t size_t;
typedef int int32_t;
typedef unsigned char uint8_t;

#define __restrict


/*******************************************************************
 * Copied verbatim to wrapper. Contains the C++-visible includes, and
 * the language includes for their respective matrix libraries.
 *******************************************************************/

%{

#include <stdint.h>
#include <omp.h>

#include "IndexFlat.h"
#include "VectorTransform.h"
#include "IndexLSH.h"
#include "IndexPQ.h"
#include "IndexIVF.h"
#include "IndexIVFPQ.h"
#include "IndexIVFFlat.h"
#include "IndexScalarQuantizer.h"
#include "HNSW.h"
#include "IndexHNSW.h"
#include "MetaIndexes.h"
#include "FaissAssert.h"

#include "IndexBinaryFlat.h"
#include "IndexBinaryIVF.h"
#include "IndexBinaryFromFloat.h"
#include "IndexBinaryHNSW.h"

#include "index_io.h"

#include "IVFlib.h"
#include "utils.h"
#include "Heap.h"
#include "AuxIndexStructures.h"
#include "OnDiskInvertedLists.h"

#include "Clustering.h"

#include "hamming.h"

#include "AutoTune.h"

 %}

/*******************************************************************
 * Types of vectors we want to manipulate at the scripting language
 * level.
 *******************************************************************/

// simplified interface for vector
namespace std {

    template<class T>
    class vector {
    public:
        vector();
        void push_back(T);
        void clear();
        T * data();
        size_t size();
        T at (size_t n) const;
        void resize (size_t n);
        void swap (vector<T> & other);
    };
};



%template(FloatVector) std::vector<float>;
%template(DoubleVector) std::vector<double>;
%template(ByteVector) std::vector<uint8_t>;
%template(CharVector) std::vector<char>;
// NOTE(hoss): Using unsigned long instead of uint64_t because OSX defines
//   uint64_t as unsigned long long, which SWIG is not aware of.
%template(Uint64Vector) std::vector<unsigned long>;
%template(LongVector) std::vector<long>;
%template(IntVector) std::vector<int>;
%template(VectorTransformVector) std::vector<faiss::VectorTransform*>;
%template(OperatingPointVector) std::vector<faiss::OperatingPoint>;
%template(InvertedListsPtrVector) std::vector<faiss::InvertedLists*>;
%template(FloatVectorVector) std::vector<std::vector<float> >;
%template(ByteVectorVector) std::vector<std::vector<unsigned char> >;
%template(LongVectorVector) std::vector<std::vector<long> >;



#ifdef GPU_WRAPPER
%template(GpuResourcesVector) std::vector<faiss::gpu::GpuResources*>;
#endif

%include <std_string.i>

 // produces an error on the Mac
%ignore faiss::hamming;


/*******************************************************************
 * Parse headers
 *******************************************************************/
%ignore *::cmp;

%include "Heap.h"
%include "hamming.h"

int get_num_gpus();

#ifdef GPU_WRAPPER

%{

#include "gpu/StandardGpuResources.h"
#include "gpu/GpuIndicesOptions.h"
#include "gpu/GpuClonerOptions.h"
#include "gpu/utils/MemorySpace.h"
#include "gpu/GpuIndex.h"
#include "gpu/GpuIndexFlat.h"
#include "gpu/GpuIndexIVF.h"
#include "gpu/GpuIndexIVFPQ.h"
#include "gpu/GpuIndexIVFFlat.h"
#include "gpu/GpuIndexBinaryFlat.h"
#include "gpu/IndexProxy.h"
#include "gpu/GpuAutoTune.h"
#include "gpu/GpuDistance.h"

int get_num_gpus()
{
    return faiss::gpu::getNumDevices();
}

%}

// causes weird wrapper bug
%ignore *::getMemoryManager;
%ignore *::getMemoryManagerCurrentDevice;

%include "gpu/GpuResources.h"
%include "gpu/StandardGpuResources.h"

#else

%{
int get_num_gpus()
{
    return 0;
}
%}


#endif


%include "utils.h"

%include "Index.h"
%include "Clustering.h"

%ignore faiss::ProductQuantizer::get_centroids(size_t,size_t) const;

%include "ProductQuantizer.h"

%include "VectorTransform.h"
%include "IndexFlat.h"
%include "IndexLSH.h"
%include "PolysemousTraining.h"
%include "IndexPQ.h"
%include "InvertedLists.h"
%ignore InvertedListScanner;
%ignore BinaryInvertedListScanner;
%include "IndexIVF.h"
// NOTE(hoss): SWIG (wrongly) believes the overloaded const version shadows the
//   non-const one.
%warnfilter(509) extract_index_ivf;
%include "IVFlib.h"
%include "IndexScalarQuantizer.h"
%include "HNSW.h"
%include "IndexHNSW.h"
%include "IndexIVFFlat.h"
%include "OnDiskInvertedLists.h"

%ignore faiss::IndexIVFPQ::alloc_type;
%include "IndexIVFPQ.h"

%include "IndexBinary.h"
%include "IndexBinaryFlat.h"
%include "IndexBinaryIVF.h"
%include "IndexBinaryFromFloat.h"
%include "IndexBinaryHNSW.h"


%include "MetaIndexes.h"
#ifdef GPU_WRAPPER

// quiet SWIG warnings
%ignore faiss::gpu::GpuIndexIVF::GpuIndexIVF;
%ignore faiss::gpu::IndexProxy::at(int) const;

%include "gpu/GpuIndicesOptions.h"
%include "gpu/GpuClonerOptions.h"
%include "gpu/utils/MemorySpace.h"
%include "gpu/GpuIndex.h"
%include "gpu/GpuIndexFlat.h"
%include "gpu/GpuIndexIVF.h"
%include "gpu/GpuIndexIVFPQ.h"
%include "gpu/GpuIndexIVFFlat.h"
%include "gpu/GpuIndexBinaryFlat.h"
%include "gpu/IndexProxy.h"
%include "gpu/GpuDistance.h"

#endif


/*******************************************************************
 * downcast return of some functions so that the sub-class is used
 * instead of the generic upper-class.
 *******************************************************************/
#ifdef SWIGJAVA

%define DOWNCAST(subclass)
    if (dynamic_cast<faiss::subclass *> ($1)) {
        faiss::subclass *instance_ptr = (faiss::subclass *)$1;
        $result = (jlong)instance_ptr;
    } else
%enddef

%define DOWNCAST_GPU(subclass)
    if (dynamic_cast<faiss::gpu::subclass *> ($1)) {
        faiss::subclass *instance_ptr = (faiss::subclass *)$1;
        $result = (jlong)instance_ptr;
    } else
%enddef

#endif

%newobject read_index;
%newobject read_index_binary;
%newobject read_VectorTransform;
%newobject read_ProductQuantizer;
%newobject clone_index;
%newobject clone_VectorTransform;

// Subclasses should appear before their parent
%typemap(out) faiss::Index * {
    DOWNCAST ( IndexIDMap )
    DOWNCAST ( IndexShards )
    DOWNCAST ( IndexIVFPQR )
    DOWNCAST ( IndexIVFPQ )
    DOWNCAST ( IndexIVFScalarQuantizer )
    DOWNCAST ( IndexIVFFlatDedup )
    DOWNCAST ( IndexIVFFlat )
    DOWNCAST ( IndexIVF )
    DOWNCAST ( IndexFlat )
    DOWNCAST ( IndexPQ )
    DOWNCAST ( IndexScalarQuantizer )
    DOWNCAST ( IndexLSH )
    DOWNCAST ( IndexPreTransform )
    DOWNCAST ( MultiIndexQuantizer )
    DOWNCAST ( IndexHNSWFlat )
    DOWNCAST ( IndexHNSWPQ )
    DOWNCAST ( IndexHNSWSQ )
    DOWNCAST ( IndexHNSW2Level )
    DOWNCAST ( Index2Layer )
#ifdef GPU_WRAPPER
    DOWNCAST_GPU ( IndexProxy )
    DOWNCAST_GPU ( GpuIndexIVFPQ )
    DOWNCAST_GPU ( GpuIndexIVFFlat )
    DOWNCAST_GPU ( GpuIndexFlat )
#endif
    // default for non-recognized classes
    DOWNCAST ( Index )
    if ($1 == NULL)
    {
#ifdef SWIGJAVA
        $result = 0;
#endif
        // Lua does not need a push for nil
    } else {
        assert(false);
    }
}

%typemap(out) faiss::IndexBinary * {
    DOWNCAST ( IndexBinaryIVF )
    DOWNCAST ( IndexBinaryFlat )
    DOWNCAST ( IndexBinaryFromFloat )
    DOWNCAST ( IndexBinaryHNSW )
#ifdef GPU_WRAPPER
    DOWNCAST_GPU ( GpuIndexBinaryFlat )
#endif
    // default for non-recognized classes
    DOWNCAST ( IndexBinary )
    if ($1 == NULL)
    {
#ifdef SWIGJAVA
        $result = 0;
#endif
        // Lua does not need a push for nil
    } else {
        assert(false);
    }
}

%typemap(out) faiss::VectorTransform * {
    DOWNCAST (RemapDimensionsTransform)
    DOWNCAST (OPQMatrix)
    DOWNCAST (PCAMatrix)
    DOWNCAST (RandomRotationMatrix)
    DOWNCAST (LinearTransform)
    DOWNCAST (NormalizationTransform)
    DOWNCAST (VectorTransform)
    {
        assert(false);
    }
}

// just to downcast pointers that come from elsewhere (eg. direct
// access to object fields)
%inline %{
faiss::Index * downcast_index (faiss::Index *index)
{
    return index;
}
faiss::VectorTransform * downcast_VectorTransform (faiss::VectorTransform *vt)
{
    return vt;
}
faiss::IndexBinary * downcast_IndexBinary (faiss::IndexBinary *index)
{
    return index;
}
%}


%include "index_io.h"

%newobject index_factory;
%newobject index_binary_factory;

%include "AutoTune.h"


#ifdef GPU_WRAPPER

%newobject index_gpu_to_cpu;
%newobject index_cpu_to_gpu;
%newobject index_cpu_to_gpu_multiple;

%include "gpu/GpuAutoTune.h"

#endif


/*******************************************************************
 * How should the template objects apprear in the scripting language?
 *******************************************************************/

// answer: the same as the C++ typedefs, but we still have to redefine them

%template() faiss::CMin<float, long>;
%template() faiss::CMin<int, long>;
%template() faiss::CMax<float, long>;
%template() faiss::CMax<int, long>;

%template(float_minheap_array_t) faiss::HeapArray<faiss::CMin<float, long> >;
%template(int_minheap_array_t) faiss::HeapArray<faiss::CMin<int, long> >;

%template(float_maxheap_array_t) faiss::HeapArray<faiss::CMax<float, long> >;
%template(int_maxheap_array_t) faiss::HeapArray<faiss::CMax<int, long> >;


/*******************************************************************
 * Expose a few basic functions
 *******************************************************************/


void omp_set_num_threads (int num_threads);
int omp_get_max_threads ();
void *memcpy(void *dest, const void *src, size_t n);


/*******************************************************************
 * For Faiss/Pytorch interop via pointers encoded as longs
 *******************************************************************/

%inline %{
float * cast_integer_to_float_ptr (long x) {
    return (float*)x;
}

long * cast_integer_to_long_ptr (long x) {
    return (long*)x;
}

int * cast_integer_to_int_ptr (long x) {
    return (int*)x;
}

%}



/*******************************************************************
 * Range search interface
 *******************************************************************/

%ignore faiss::BufferList::Buffer;
%ignore faiss::RangeSearchPartialResult::QueryResult;
%ignore faiss::IDSelectorBatch::set;
%ignore faiss::IDSelectorBatch::bloom;

%include "AuxIndexStructures.h"

%{
// may be useful for lua code launched in background from shell

#include <signal.h>
void ignore_SIGTTIN() {
    signal(SIGTTIN, SIG_IGN);
}
%}

void ignore_SIGTTIN();


%inline %{

// numpy misses a hash table implementation, hence this class. It
// represents not found values as -1 like in the Index implementation

struct MapLong2Long {
    std::unordered_map<long, long> map;

    void add(size_t n, const long *keys, const long *vals) {
        map.reserve(map.size() + n);
        for (size_t i = 0; i < n; i++) {
            map[keys[i]] = vals[i];
        }
    }

    long search(long key) {
        if (map.count(key) == 0) {
            return -1;
        } else {
            return map[key];
        }
    }

    void search_multiple(size_t n, const long *keys, long * vals) {
        for (size_t i = 0; i < n; i++) {
            vals[i] = search(keys[i]);
        }
    }
};

%}

// End of file...
