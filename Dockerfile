# Wan 2.2 I2V + SVI 2.0 Pro — RunPod Serverless ComfyUI Worker
# All models baked in (~24GB total). No network volume needed.
FROM runpod/worker-comfyui:5.7.1-base

# Install custom nodes for video output and Wan I2V encoding
RUN comfy-node-install comfyui-videohelpersuite

# WanVideoWrapper provides WanImageToVideoEncoding node
# Try registry first, fall back to git clone
RUN comfy-node-install comfyui-wanvideowrapper 2>/dev/null || \
    (cd /comfyui/custom_nodes && \
     git clone https://github.com/kijai/ComfyUI-WanVideoWrapper && \
     pip install -r ComfyUI-WanVideoWrapper/requirements.txt 2>/dev/null; true)

# Use wget instead of `comfy model download` — the comfy CLI is interactive
# and aborts in non-TTY Docker builds.

# --- Wan 2.2 I2V Diffusion Models (fp8 quantized, ~8.5GB each) ---
RUN wget -q --show-progress -O /comfyui/models/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors"

RUN wget -q --show-progress -O /comfyui/models/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors"

# --- Text Encoder (fp8, ~4.9GB) ---
RUN wget -q --show-progress -O /comfyui/models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

# --- VAE (~0.3GB) ---
RUN wget -q --show-progress -O /comfyui/models/vae/wan_2.1_vae.safetensors \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"

# --- SVI 2.0 Pro LoRAs (~1.2GB each) ---
RUN wget -q --show-progress -O /comfyui/models/loras/SVI_v2_PRO_Wan2.2-I2V-A14B_HIGH_lora_rank_128_fp16.safetensors \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Stable-Video-Infinity/v2.0/SVI_v2_PRO_Wan2.2-I2V-A14B_HIGH_lora_rank_128_fp16.safetensors"

RUN wget -q --show-progress -O /comfyui/models/loras/SVI_v2_PRO_Wan2.2-I2V-A14B_LOW_lora_rank_128_fp16.safetensors \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Stable-Video-Infinity/v2.0/SVI_v2_PRO_Wan2.2-I2V-A14B_LOW_lora_rank_128_fp16.safetensors"

# Copy workflow template (for reference; workflow is sent in API payload at runtime)
COPY workflow_template.json /app/workflow_template.json
