# Wan 2.2 I2V + SVI 2.0 Pro — RunPod Serverless ComfyUI Worker
# All models baked in (~24GB total). No network volume needed.
FROM runpod/worker-comfyui:5.7.1-base

# Install custom nodes for video output and Wan I2V encoding
RUN comfy-node-install comfyui-videohelpersuite

# WanVideoWrapper provides WanImageToVideoEncoding node
RUN comfy-node-install comfyui-wanvideowrapper 2>/dev/null || \
    (cd /comfyui/custom_nodes && \
     git clone https://github.com/kijai/ComfyUI-WanVideoWrapper && \
     pip install -r ComfyUI-WanVideoWrapper/requirements.txt 2>/dev/null; true)

# Download ALL models in a single layer to minimize disk usage during build.
# Total: ~24GB (2x8.5GB diffusion + 4.9GB text enc + 0.3GB VAE + 2x1.2GB LoRAs)
RUN wget -q -O /comfyui/models/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors \
      "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors" && \
    wget -q -O /comfyui/models/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors \
      "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors" && \
    wget -q -O /comfyui/models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors \
      "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" && \
    wget -q -O /comfyui/models/vae/wan_2.1_vae.safetensors \
      "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" && \
    wget -q -O /comfyui/models/loras/SVI_v2_PRO_Wan2.2-I2V-A14B_HIGH_lora_rank_128_fp16.safetensors \
      "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Stable-Video-Infinity/v2.0/SVI_v2_PRO_Wan2.2-I2V-A14B_HIGH_lora_rank_128_fp16.safetensors" && \
    wget -q -O /comfyui/models/loras/SVI_v2_PRO_Wan2.2-I2V-A14B_LOW_lora_rank_128_fp16.safetensors \
      "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Stable-Video-Infinity/v2.0/SVI_v2_PRO_Wan2.2-I2V-A14B_LOW_lora_rank_128_fp16.safetensors"

COPY workflow_template.json /app/workflow_template.json
