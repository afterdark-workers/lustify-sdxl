#!/bin/sh
# Lustify SDXL — everything the worker image needs. The Dockerfile in your copy downloads this file
# from the original repo on every build, so fixes made there reach you with a rebuild.
set -eu
case "${CIVITAI_TOKEN:-}" in ""|PASTE_*) echo "ERROR: set CIVITAI_TOKEN at the top of the Dockerfile" >&2; exit 1;; esac

# file <dest> <url> <sha256>
file() {
  wget -q -O "$1" "$2"
  echo "$3  $1" | sha256sum -c - || { echo "ERROR: $1 changed upstream — wait for an update of the original repo, then rebuild" >&2; exit 1; }
}

# LUSTIFY! ZENITH (V9) — SDXL 1.0 checkpoint, fp16 pruned (Civitai model 573152 / version 3045803, 6.8GB)
file /comfyui/models/checkpoints/lustify_sdxl_v9.safetensors \
  "https://civitai.com/api/download/models/3045803?type=Model&format=SafeTensor&size=pruned&fp=fp16&token=${CIVITAI_TOKEN}" \
  1a3abf0bf48113eb5e17d2f8ae012c5b60cb97d81d79c4d9e47cd5af56c162f1
# SDXL runs on the ComfyUI of the base image as is
