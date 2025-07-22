#pragma once
#ifdef __cplusplus
extern "C" {
#endif

// 成功返回 0；失败返回非 0
int bm3d_denoise(
    const unsigned char* noisy,   // H×W (灰度) 或 H×W×3, uchar [0‒255]
    unsigned char* denoised,      // 同上
    int width, int height,        // 图像尺寸
    int channels,                 // 1 或 3
    float sigma,                  // 噪声标准差 (e.g. 25)
    bool twostep,                 // 是否做第二步
    bool verbose,                 // 是否静默
    const unsigned char* ref,     // 参考图，可为 nullptr
    float* out_psnr               // 若 ref!=nullptr 则写 PSNR
);

#ifdef __cplusplus
}
#endif
