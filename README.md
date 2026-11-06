# vps-code — the code channel for the VPS

The box pulls this repo every 5 minutes instead of using the Hugging Face relay.
That removes the 128-commits/hour limit that kept blocking deploys.

## Install once (on the VPS)

```bash
echo 'GITHUB_TOKEN=github_pat_xxx' > /etc/vps-code.env
chmod 600 /etc/vps-code.env
bash vps-pull.sh
```

After that, anything pushed here lands on the box within 5 minutes.

## Run a hook after each change

Put an executable `on-pull.sh` in the repo root. `vps-pull` runs it whenever the
head commit changes — that is where builds, restarts and renders go.
