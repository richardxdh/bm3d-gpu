cmake_minimum_required(VERSION 3.8 FATAL_ERROR)
# cmake_policy(SET CMP0104 NEW)

project(bm3d LANGUAGES CXX CUDA)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/include
	${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}
)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

if (NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES "native")  # or "75;120"
endif()

# The following lines build the main executable.
add_executable(bm3d
	include/CImg.h
	include/stopwatch.hpp
	include/indices.cuh
	include/params.hpp
	include/bm3d.hpp
	src/filtering.cu
	src/blockmatching.cu
	src/dct8x8.cu
	src/main_nodisplay.cpp
)

target_link_libraries(bm3d cufft cudart png)
