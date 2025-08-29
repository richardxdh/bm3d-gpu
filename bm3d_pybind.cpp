#include <pybind11/pybind11.h>
#include <pybind11/numpy.h>
#include "bm3d_api.h"

namespace py = pybind11;

py::tuple denoise(py::array noisy,
                  float sigma,
                  // bool color      = false,
                  bool twostep    = true,
                  bool verbose    = false,
                  py::object ref_ = py::none())
{
    /* ---- 校验/拷贝输入 ---- */
    int h,w,c;
    bool color = false;
    py::array noisy_c = py::array_t<uint8_t>(noisy);   // 强制 uint8
    if (noisy_c.ndim()==2) { h=noisy_c.shape(0); w=noisy_c.shape(1); c=1; color=false;}
    else if(noisy_c.ndim()==3 && noisy_c.shape(2)==3){ h=noisy_c.shape(0); w=noisy_c.shape(1); c=3; color=true;}
    else throw std::runtime_error("the input size must be H×W or H×W×3 uint8");

    auto dst = py::array_t<uint8_t>( noisy_c.request().shape );
    float psnr = 0.f;

    const unsigned char* ref_ptr = nullptr;
    if(!ref_.is_none()){
        py::array ref_a = py::array_t<uint8_t>(ref_);
        if (ref_a.shape(0)!=h || ref_a.shape(1)!=w || ref_a.ndim()!=(c==1?2:3))
            throw std::runtime_error("Reference image size mismatch");
        ref_ptr = static_cast<unsigned char*>( ref_a.request().ptr );
    }

    int ret = bm3d_denoise(
        static_cast<unsigned char*>(noisy_c.request().ptr),
        static_cast<unsigned char*>(dst.request().ptr),
        w, h, c, sigma,
        twostep, verbose,
        ref_ptr,
        ref_ptr? &psnr : nullptr
    );
    if(ret) throw std::runtime_error("bm3d_denoise failed");

    // if(ref_ptr) return py::make_tuple(dst, psnr);
    return py::make_tuple(dst, psnr);
}

PYBIND11_MODULE(_bm3d_gpu_impl, m){
    m.doc() = "CUDA BM3D bindings (pybind11)";
    m.def("denoise", &denoise,
          "BM3D Image Denoising",
          py::arg("noisy"),
          py::arg("sigma")    = 25.f,
          // py::arg("color")    = false,
          py::arg("twostep")  = true,
          py::arg("verbose")  = false,
          py::arg("reference")= py::none());
}
