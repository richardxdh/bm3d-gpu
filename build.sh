#!/bin/bash

# 1. 安装依赖
# conda create -n bm3d python=3.11 numpy opencv pybind11 scikit-build-core -c conda-forge
# conda activate bm3d
# CUDA Toolkit 请自行安装 (≥11.4)

set -e # Exit immediately if a command exits with a non-zero status.

echo ""
echo "======================step1: remove cache============================"
rm -rf build dist *.egg-info bm3d_gpu/*.so bm3d_gpu/*.pyd


echo ""
echo "======================step2: build python module============================"
# The 'python -m build' command handles everything:
# It calls cmake, builds the project, and creates the wheel.
python -m build -w


echo ""
echo "======================step3: install python module============================"
pip uninstall bm3d_gpu -y
pip install dist/bm3d_gpu-0.1.0-*.whl


echo ""
echo "======================step4: test python module============================"
python ./test/test.py


echo ""
echo "====================== Build and test successful! =========================="