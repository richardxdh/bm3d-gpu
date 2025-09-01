# How to Build `bm3d-gpu` on Windows

This guide provides step-by-step instructions to compile and package the `bm3d-gpu` Python module on a Windows system.

## Step 1: Install Prerequisites

Before you begin, ensure you have installed the following software:

1.  **Visual Studio 2022**:
    *   Download and install from the [official website](https://visualstudio.microsoft.com/downloads/).
    *   During installation, you **must** select the **"Desktop development with C++"** workload. This installs the required MSVC compiler and Windows SDK.

2.  **NVIDIA CUDA Toolkit**:
    *   Download and install a version compatible with your NVIDIA driver and GPU from the [NVIDIA CUDA Toolkit Archive](https://developer.nvidia.com/cuda-toolkit-archive).
    *   Ensure that the CUDA compiler (`nvcc`) directory is added to your system's `PATH` environment variable during installation.

3.  **Python**:
    *   Download and install a recent version of Python (e.g., 3.8 or newer) from the [official Python website](https://www.python.org/downloads/windows/).
    *   Ensure Python is added to your system's `PATH`.

4.  **Git**:
    *   Install Git for Windows from [git-scm.com](https://git-scm.com/download/win).

5.  **vcpkg (C++ Package Manager)**:
    *   We will use `vcpkg` to install the `libpng` dependency. Open a command prompt (CMD or PowerShell) and run the following commands to install it:
        ```bash
        # Clone the repository (you can choose a different location than C:\)
        cd C:\
        git clone https://github.com/Microsoft/vcpkg.git
        cd vcpkg

        # Run the bootstrap script
        ./bootstrap-vcpkg.bat
        ```

## Step 2: Install `libpng` Dependency

This project requires `libpng` for image handling. Use `vcpkg` to install it.

*   In the same command prompt, from the `vcpkg` directory, run:
    ```bash
    ./vcpkg install libpng:x64-windows
    ```

## Step 3: Prepare the Codebase

The necessary modifications have already been applied to the files `CMakeLists.txt` and `src/filtering.cu` to ensure compatibility with the MSVC compiler and Windows environment. The build process will use these modified files.

## Step 4: Compile and Package the Python Module

1.  **Open the Correct Command Prompt**:
    *   It is crucial to use a command prompt that has the Visual Studio environment configured. Go to your **Start Menu** and search for **"x64 Native Tools Command Prompt for VS 2022"** and open it. All subsequent commands should be run in this terminal.

2.  **Navigate to the Project Directory**:
    ```cmd
    cd /d C:\path\to\your\bm3d-gpu
    ```
    *(Replace with the actual path to the project)*

3.  **Create a Python Virtual Environment** (Recommended):
    ```cmd
    python -m venv .venv
    .venv\Scripts\activate
    ```

4.  **Install Python Build Dependencies**:
    ```cmd
    python -m pip install --upgrade pip
    python -m pip install scikit-build-core pybind11 numpy ninja
    ```

5.  **Configure CMake to Use vcpkg**:
    *   You must tell CMake where to find the libraries installed by `vcpkg` by setting the `CMAKE_ARGS` environment variable.
    *   **Important**: Replace `C:\vcpkg` with the actual path where you cloned `vcpkg`.
    ```cmd
    set "CMAKE_ARGS=-DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake"
    ```

6.  **Run the Build**:
    *   Execute the build command to compile the project and create a Python wheel package.
    *   Using `--verbose` is helpful for debugging if you encounter issues.
    ```cmd
    python -m pip wheel . --verbose
    ```

After the command finishes successfully, you will find a `.whl` file in the project's root directory. You can install this file using pip:

```cmd
pip install bm3d_gpu-*.whl
```

You can now `import bm3d_gpu` in your Python scripts.

```