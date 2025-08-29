cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
# Use C++17 as required by modern CUDA/Thrust versions
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

project(bm3d_gpu_project LANGUAGES CXX CUDA)

# Undefine CImg macros to prevent dependency on external libraries
# We modify the global flags here as a more forceful approach to ensure
# the flags are passed correctly by the build system.
if(MSVC)
  # For C++ files (.cpp)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Ucimg_use_jpeg /Ucimg_use_png /Ucimg_display")
  # For CUDA files (.cu)
  set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -Xcompiler /Ucimg_use_jpeg -Xcompiler /Ucimg_use_png -Xcompiler /Ucimg_display")
else()
  # For other compilers (GCC, Clang)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Ucimg_use_jpeg -Ucimg_use_png -Ucimg_display")
  set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -Ucimg_use_jpeg -Ucimg_use_png -Ucimg_display")
endif()

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

if (NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES "native")
endif()

# ---------- Dependencies ----------
find_package(CUDAToolkit REQUIRED)
set(PYBIND11_FINDPYTHON ON)
find_package(pybind11 CONFIG REQUIRED)

# ---------- Core static library ----------
add_library(bm3d_core STATIC
    src/bm3d_api.cpp
    src/filtering.cu
    src/blockmatching.cu
    src/dct8x8.cu
)
target_include_directories(bm3d_core PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CUDAToolkit_INCLUDE_DIRS}
)
target_link_libraries(bm3d_core PUBLIC cufft cudart)

# ---------- Python module ----------
pybind11_add_module(_bm3d_gpu_impl MODULE bm3d_pybind.cpp)
target_link_libraries(_bm3d_gpu_impl PRIVATE bm3d_core)
set_target_properties(_bm3d_gpu_impl PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bm3d_gpu
    CUDA_ARCHITECTURES ${CMAKE_CUDA_ARCHITECTURES}
)