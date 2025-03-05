#!/bin/bash
cmake ../../../ \
-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
-DCMAKE_BUILD_TYPE=Release \
-DANDROID_ABI="arm64-v8a" \
-DANDROID_STL=c++_static \
-DMNN_USE_LOGCAT=false \
-DMNN_ARM82=ON \
-DMNN_BUILD_BENCHMARK=ON \
-DMNN_USE_SSE=OFF \
-DMNN_NNAPI=ON \
-DMNN_NeuronAdapter=ON \
-DMNN_OPENCL=ON \
-DMNN_SEP_BUILD=OFF \
-DMNN_BUILD_TEST=ON \
-DANDROID_NATIVE_API_LEVEL=android-21  \
-DMNN_BUILD_FOR_ANDROID_COMMAND=true \
-DMNN_SUPPORT_TRANSFORMER_FUSE=true \
-DNATIVE_LIBRARY_OUTPUT=. -DNATIVE_INCLUDE_OUTPUT=. $1 $2 $3 $4 $5 $6 $7

make -j4
