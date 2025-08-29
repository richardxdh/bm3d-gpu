@echo off
setlocal

echo ========================================================================
echo  Windows Build Script for bm3d_gpu
echo ========================================================================
echo.
echo This script will build and install the bm3d_gpu Python package.
echo.
echo Prerequisites:
echo 1. Visual Studio 2019 or later with "Desktop development with C++" workload.
echo 2. NVIDIA CUDA Toolkit (>=11.4). Make sure 'nvcc' is in your PATH.
echo 3. Python (>=3.8).
echo.
echo Make sure you are running this script from a command prompt with the
echo correct environment set up (e.g., "x64 Native Tools Command Prompt for VS").
echo.
pause
echo.

echo ====================== step0: install dependencies ===========================
echo Installing Python dependencies...
pip install build numpy pybind11 scikit-build-core ninja
if %errorlevel% neq 0 (
    echo Failed to install python dependencies.
    exit /b 1
)
echo.

echo ====================== step1: remove cache ============================
echo Cleaning up previous builds...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist bm3d_gpu.egg-info rmdir /s /q bm3d_gpu.egg-info
del /q bm3d_gpu\*.pyd
echo.

echo ====================== step2: build python module ===========================
echo Building the Python wheel...
python -m build -w
if %errorlevel% neq 0 (
    echo Build failed.
    exit /b 1
)
echo.

echo ====================== step3: install python module ===========================
echo Uninstalling previous version...
pip uninstall bm3d_gpu -y
echo Installing new version...
pip install dist/bm3d_gpu-0.1.0-*.whl
if %errorlevel% neq 0 (
    echo Installation failed.
    exit /b 1
)
echo.

echo ====================== step4: test python module ===========================
echo Running tests...
python ./test/test.py
if %errorlevel% neq 0 (
    echo Tests failed.
    exit /b 1
)
echo.

echo ========================================================================
echo  Build and test completed successfully!
echo ========================================================================

endlocal
