cmake_minimum_required(VERSION 3.15 FATAL_ERROR)
# cmake_policy(SET CMP0104 NEW)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF) 

if(CMAKE_GENERATOR STREQUAL "Ninja")
    set_property(GLOBAL PROPERTY JOB_POOLS link_lto=8)
    set(CMAKE_JOB_POOLS_LINK link_lto)
endif()

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

project(bm3d LANGUAGES CXX CUDA)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/include
	${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}
)

if (NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES "native")  # or "75;120"
endif()

# ---------- 依赖 ----------
set(PYBIND11_FINDPYTHON ON)
find_package(pybind11 CONFIG REQUIRED)
enable_language(CUDA)
find_package(CUDAToolkit REQUIRED)


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

# ---------- Core 静态库 ----------
add_library(bm3d_core STATIC
    src/bm3d_api.cpp
	include/CImg.h
	include/stopwatch.hpp
	include/indices.cuh
	include/params.hpp
	include/bm3d.hpp
	src/filtering.cu
	src/blockmatching.cu
	src/dct8x8.cu
)
target_link_libraries(bm3d_core PUBLIC cudart cufft png)

# ---------- Python 模块 ----------
pybind11_add_module(bm3d_gpu MODULE bm3d_pybind.cpp)
target_link_libraries(bm3d_gpu PRIVATE bm3d_core)
set_target_properties(bm3d_gpu PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bm3d_gpu
    CUDA_ARCHITECTURES "native"
)
