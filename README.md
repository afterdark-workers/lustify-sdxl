# Lustify SDXL — RunPod Serverless worker

A ready-to-build [RunPod Serverless](https://www.runpod.io/serverless-gpu) worker for **LUSTIFY! ZENITH (V9)**, a photoreal SDXL checkpoint. Based on the official [`runpod/worker-comfyui`](https://github.com/runpod-workers/worker-comfyui).

Models are baked into the image, so a cold start does not re-download anything.

> 18+ model. You download it with your own Civitai account and are responsible for following the model licenses.

## What's inside

| File | Source | Size |
|---|---|---|
| `checkpoints/lustify_sdxl_v9.safetensors` | Civitai 573152 / version 3045803 (fp16 pruned) | 6.8 GB |

Just the model as its creator released it — no LoRAs, no extra nodes, no upscalers. The file is checked by SHA-256 at build time. SDXL runs on the ComfyUI of the base image, so nothing else is installed.

## Setup (about 10 minutes + build time)

New to this? Follow the [step-by-step setup guide](https://cobaltpear.github.io/guide.html).

1. **Make your own private copy** — click **Use this template** → **Create a new repository** → choose **Private**.
   (Your Civitai token will be in it, so it must stay private.)
2. **Add your Civitai token** — get one at civitai.com → Account settings → API Keys.
   In your copy, open `Dockerfile` → ✏️ edit → replace `PASTE_YOUR_CIVITAI_TOKEN_HERE` on line 5 → Commit.
   No RunPod account yet? [Sign up here](https://runpod.io?ref=qpguwapm) — a referral link: after you first add $10, RunPod gives you a bonus credit (usually $5–10) and this repo a small credit.
3. **Create the endpoint** — RunPod → Serverless → New Endpoint → GitHub Repo → pick your copy:

   | Setting | Value |
   |---|---|
   | Branch / Dockerfile path / Build context | `main` / `Dockerfile` / `.` |
   | GPU | 16 GB or more |
   | Active / Max workers | 0 / 1 |
   | Idle timeout | 5 s |
   | Execution timeout | 600 s |
   | FlashBoot | On |
   | Container disk | 20 GB |

   The first build takes about 15 minutes. The very first request after that waits another 3–10 minutes while a worker pulls the image; later cold starts are much faster.
4. **Create an API key** — RunPod → Settings → API Keys → **Restricted**, allow only this endpoint.

## Updates

Your copy only holds the token. The build steps (`build.sh`, `handler.py`) are downloaded from this repo on every build, so when something changes upstream (a model file is replaced, ComfyUI needs an update) it is fixed here — you just rebuild your endpoint.

To rebuild: in your copy on GitHub, **Releases → Draft a new release** → any new tag (e.g. `v2`) → **Publish**. RunPod builds again on every new release (a plain commit does not trigger a build).

### Model version

`main` always follows the version the model's creator currently recommends. Now: **ZENITH (V9), Civitai version 3045803** — the last SDXL version (newer Lustify versions are built on another base model and get their own repo).
When it moves to a new version, the old one is kept as a tag (e.g. `v3045803`). To stay on it, replace `main` with that tag in both `ADD` lines of your `Dockerfile`.

## Use it

Any client that sends ComfyUI API-format workflows to RunPod works. `pack.json` in this repo holds the workflow and tells a client where the prompt, seed and size go (format `pack/1`, engine `comfyui`).

Raw request:

```bash
curl -X POST https://api.runpod.ai/v2/<ENDPOINT_ID>/runsync \
  -H "Authorization: Bearer <API_KEY>" -H "Content-Type: application/json" \
  -d "{\"input\": {\"workflow\": $(jq .workflow pack.json | jq '.["6"].inputs.text = "a photo of a woman reading in a cafe" | .["3"].inputs.seed = 1 | .["5"].inputs.width = 1216 | .["5"].inputs.height = 832')}}"
```

The image comes back as base64 in `output.images[0].data`.

Tips: 30 steps, CFG 4, DPM++ 2M SDE Karras, negative `old, ugly, blurry` — the creator's sample settings. Many of the creator's samples also add camera words for a photo look, e.g. `(helios 44, Fujifilm GFX 50R, bokeh, depth of field:1.15)` — add them yourself if you want that look. SDXL sizes: about 1 megapixel, multiples of 64.

### Compatible clients

- [Cobalt Pear](https://cobaltpear.github.io/) — a one-page web app: add this repo's URL, your endpoint ID and API key, then just type a prompt. Everything stays in your browser. [Try the demo](https://cobaltpear.github.io/demo/) without RunPod.

Questions or ideas: [Discussions](https://github.com/cobaltpear/cobaltpear.github.io/discussions).
