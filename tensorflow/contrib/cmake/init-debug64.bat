c:\dev\tools\cmake-3.7.2\bin\cmake .. ^
-G"Visual Studio 14 2015 Win64" ^
-DCMAKE_GENERATOR="Visual Studio 14 2015 Win64" ^
-DCMAKE_BUILD_TYPE=Debug ^
-Dtensorflow_BUILD_SHARED_LIB=TRUE ^
-Dtensorflow_BUILD_PYTHON_BINDINGS=OFF ^
-DBUILD_SHARED_LIBS=false ^
-Dtensorflow_ENABLE_GRPC_SUPPORT=OFF ^
-Dtensorflow_BUILD_CC_TESTS=OFF ^
-Dtensorflow_OPTIMIZE_FOR_NATIVE_ARCH=true ^
-Dtensorflow_WIN_CPU_SIMD_OPTIONS=/arch:AVX ^
-DCMAKE_INSTALL_PREFIX=C:\dev\dist\msvc14\amd64\tensorflow\debug
