cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
# Use C++17 as required by modern CUDA/Thrust versions
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

project(bm3d_gpu_project LANGUAGES CXX CUDA)

# Fix for pybind11 developer warning
set(PYBIND11_FINDPYTHON ON)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

if (NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES "native")
endif()

# ---------- Dependencies ----------
find_package(CUDAToolkit REQUIRED)
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

# Undefine CImg macros to prevent dependency on external libraries
if(MSVC)
  set(cxx_undef_flags "/Ucimg_use_jpeg" "/Ucimg_use_png" "/Ucimg_display")
  # For nvcc, -Xcompiler and its argument must be passed as separate arguments
  set(cuda_undef_flags 
      "-Xcompiler" "/Ucimg_use_jpeg"
      "-Xcompiler" "/Ucimg_use_png"
      "-Xcompiler" "/Ucimg_display"
  )
else()
  set(cxx_undef_flags "-Ucimg_use_jpeg" "-Ucimg_use_png" "-Ucimg_display")
  set(cuda_undef_flags ${cxx_undef_flags}) # On Linux, nvcc accepts -U directly
endif()

target_compile_options(bm3d_core PRIVATE
    $<$<COMPILE_LANGUAGE:CXX>:${cxx_undef_flags}>
    $<$<COMPILE_LANGUAGE:CUDA>:${cuda_undef_flags}>
)

target_link_libraries(bm3d_core PUBLIC cufft cudart)

# ---------- Python module ----------
pybind11_add_module(_bm3d_gpu_impl MODULE bm3d_pybind.cpp)
target_link_libraries(_bm3d_gpu_impl PRIVATE bm3d_core)

# Using both methods to be extra robust.
# 1. Place the library in the source tree directly.
set_target_properties(_bm3d_gpu_impl PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bm3d_gpu
    CUDA_ARCHITECTURES ${CMAKE_CUDA_ARCHITECTURES}
)

# 2. Also provide a standard install rule for the packager.
install(TARGETS _bm3d_gpu_impl
        LIBRARY DESTINATION bm3d_gpu)