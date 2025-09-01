# -*- coding: utf8 -*-
import os
from pathlib import Path
import cv2
import bm3d_gpu

cur_dir = Path(__file__).parent

print("module file :", Path(bm3d_gpu.__file__).resolve())
print("denoise sig :", bm3d_gpu.denoise.__name__)


def test_func(noisy_dir, denoised_dir):

    ref_img = cv2.imread(noisy_dir / "lena.png", cv2.IMREAD_GRAYSCALE)

    for noisy_path in sorted(noisy_dir.glob("*.png")):

        if not noisy_path.stem.endswith("0"):
            continue

        print("noisy image :", noisy_path)

        sigma = int(noisy_path.stem[-2:])

        noisy_img = cv2.imread(noisy_path, cv2.IMREAD_GRAYSCALE)

        denoised_img, psnr = bm3d_gpu.denoise(
            noisy_img, sigma=sigma, reference=ref_img
        )

        os.makedirs(denoised_dir, exist_ok=True)
        denoised_path = denoised_dir / noisy_path.name
        cv2.imwrite(denoised_path, denoised_img)


if __name__ == "__main__":

    input_dir = cur_dir / "noisy"
    output_dir = cur_dir / "denoised"

    test_func(input_dir, output_dir)
