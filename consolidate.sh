#!/bin/bash

#
#### Inclusion path (order matters):
#
# include/external/nsync/public
# include/externaleigen_archive
# include/
# include/eigen3
#
#

SOURCE_FOLDER=$1
COMPILATION_FOLDER=$2
#VERBOSE=" -v "

CREATE_DIR="1"

if [ "$1" == "" ] || [ "$2" == "" ]; then

echo "Usage: $0 [path of TensorFlow source] [path of TensorFlow compilation folder]"
exit
fi


mkdir -p include
mkdir -p lib
mkdir -p bin

#
# Strip path of a filename
#
# ex. : /my/file/is/here.txt => here.txt is stored in STRIPPED var
#
function StripPath {
    STRIPPED=`echo $1 | sed -e "s|.*\/||g"`
}


# 1. Collect headers (*.h) files from source and build folders
echo -n "Collecting headers files..."

find $SOURCE_FOLDER -type f -name *.h  | grep -v "cmake/build" > _src_headers.txt
find $COMPILATION_FOLDER -type f -name *.h  > _build_headers.txt

echo "Ok."

echo -n "Extracting unique headers folders..."

cat _src_headers.txt | sed -e 's#^\(.*/\)[^\/]*$#\1#g' | sed -e "s#$SOURCE_FOLDER##g" | uniq > _src_headers_folders.txt
cat _build_headers.txt | sed -e 's#\(.*/\)[^\/]*#\1#g' | sed -e "s#$COMPILATION_FOLDER##g" | uniq > _build_headers_folders.txt

echo "Ok."

mapfile -t SRC_HEADERS_WITH_FULL_PATH   < _src_headers.txt
mapfile -t BUILD_HEADERS_WITH_FULL_PATH < _build_headers.txt
mapfile -t SRC_HEADERS_FOLDERS          < _src_headers_folders.txt
mapfile -t BUILD_HEADERS_FOLDERS        < _build_headers_folders.txt

# 2. Create folder structure
echo "---- Headers folder structure creation (src)"
for folder in "${SRC_HEADERS_FOLDERS[@]}"; do
  echo "--(src) Creating include/$folder"
  mkdir -p include/$folder
done

echo "---- Headers folder structure creation (build)"
for folder in "${BUILD_HEADERS_FOLDERS[@]}"; do
  echo "--(build) Creating include/$folder"
  mkdir -p include/$folder
done


# 3. Copy source headers into include/
#    -> respect the folder structure

echo "---- Headers copy (src)"


# each header file path without the source folder prefix
SRC_HEADERS_WITH_CLEAN_PATH=(`sed -e "s|$SOURCE_FOLDER||g" _src_headers.txt`)
for ((i=0;i<${#SRC_HEADERS_WITH_FULL_PATH[@]};++i)); do

    FULL_PATH=${SRC_HEADERS_WITH_FULL_PATH[i]}
    CLEAN_PATH=${SRC_HEADERS_WITH_CLEAN_PATH[i]}
    
    if [ "$VERBOSE" == "-v" ]; then
        echo "Full/Clean: $FULL_PATH <=> $CLEAN_PATH"
    fi
    cp $VERBOSE $FULL_PATH include/$CLEAN_PATH
done

echo "---- Headers copy (build)"
BUILD_HEADERS_WITH_CLEAN_PATH=(`sed -e "s|$COMPILATION_FOLDER||g" _build_headers.txt`)
for ((i=0;i<${#BUILD_HEADERS_WITH_FULL_PATH[@]};++i)); do

    FULL_PATH=${BUILD_HEADERS_WITH_FULL_PATH[i]}
    CLEAN_PATH=${BUILD_HEADERS_WITH_CLEAN_PATH[i]}
    
    if [ "$VERBOSE" == "-v" ]; then
        echo "Full/Clean: $FULL_PATH <=> $CLEAN_PATH"
    fi
    cp $VERBOSE $FULL_PATH include/$CLEAN_PATH
done


echo "---- Eigen Headers copy (header without extension)"

find $COMPILATION_FOLDER -type f ! -name "*.*" | grep -i "eigen" | grep -v "_|\-" > _eigen_headers.txt
sed -e "s|$COMPILATION_FOLDER||g"  _eigen_headers.txt > _filtered_eigen_headers.txt

EIGEN_HEADERS_WITH_FULL_PATH=(`cat _eigen_headers.txt`)
EIGEN_HEADERS_WITH_CLEAN_PATH=(`cat _filtered_eigen_headers.txt`)

for ((i=0;i<${#EIGEN_HEADERS_WITH_FULL_PATH[@]};++i)); do
    FULL_PATH=${BUILD_HEADERS_WITH_FULL_PATH[i]}
    CLEAN_PATH=${BUILD_HEADERS_WITH_CLEAN_PATH[i]}
    if [ "$VERBOSE" == "-v" ]; then
        echo "Full/Clean: $FULL_PATH <=> $CLEAN_PATH"
    fi
    cp $VERBOSE $FULL_PATH include/$CLEAN_PATH
done

echo "---- Executables copy"
for executable in `find $COMPILATION_FOLDER/Release/ -name *.exe`; do
    cp $VERBOSE $executable bin/
done


echo "---- Binary libraries copy"
# copy binaries in lib/ folder
for lib in `find $COMPILATION_FOLDER -name 'tensorflow.lib'`; do 
    StripPath "$lib"
    echo "-- $STRIPPED"
    cp  $lib lib/
done
for lib in `find $COMPILATION_FOLDER -name 'tensorflow.dll'`; do 
    StripPath "$lib"
    echo "-- $STRIPPED"
    cp  $lib lib/
done


echo "Realignment for Eigen library"
cp $COMPILATION_FOLDER/eigen/src/eigen/unsupported/Eigen/CXX11/Tensor include/third_party/eigen3/unsupported/Eigen/CXX11/
cp $COMPILATION_FOLDER/eigen/src/eigen/Eigen include/third_party/eigen3/ -r
cp include/eigen/src/eigen/Eigen/src/ include/eigen/ -r

echo "Copy TensorFlow Eigen extension"
cp -r $SOURCE_FOLDER/third_party/eigen3 include/third_party/

echo "Fix protobuf"
mv include/protobuf/src/protobuf/src/google include/
