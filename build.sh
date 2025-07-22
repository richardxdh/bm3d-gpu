
# 1. 安装依赖
# conda create -n bm3d python=3.11 numpy opencv pybind11 scikit-build-core -c conda-forge
# conda activate bm3d
# CUDA Toolkit 请自行安装 (≥11.4)


echo ""
echo "======================step1: remove cache============================"
rm -rf build dist *.egg-info bm3d_gpu/*.so


echo ""
echo "======================step2: cmake build============================"
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -j
# cmake -S .. -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
# cmake --build build -j8


echo ""
echo "======================step3: build python module============================"
cd ..
python -m build -w


echo ""
echo "======================step4: install python module============================"
pip uninstall bm3d_gpu -y
pip install dist/bm3d_gpu-0.1.0-*.whl


echo ""
echo "======================step5: test python module============================"
python ./test/test.py
