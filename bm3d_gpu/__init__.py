import os
import sys

# On Windows, add the CUDA bin directory to the DLL search path.
# This is required for Python 3.8+ to find the CUDA DLLs.
if sys.platform == 'win32':
    # Get CUDA path from environment variable.
    # CUDA_PATH is set by the CUDA installer.
    cuda_path = os.environ.get('CUDA_PATH')
    if cuda_path:
        bin_path = os.path.join(cuda_path, 'bin')
        if os.path.isdir(bin_path):
            # print(f"Adding CUDA bin to DLL search path: {bin_path}") # for debugging
            try:
                os.add_dll_directory(bin_path)
            except (AttributeError, FileNotFoundError):
                # os.add_dll_directory is available on Python 3.8+
                # If it fails, we hope the DLLs are in the PATH.
                pass
    else:
        # print("CUDA_PATH environment variable not found.") # for debugging
        pass

from ._bm3d_gpu_impl import *
