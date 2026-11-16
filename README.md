# sotk2 Shiny app

Source for the [sotk2](https://github.com/Snyder-Institute/sotk2) demo Shiny app. The app provides an interactive walkthrough of the sotk2 workflow on three glioma cohorts (GLASS, IVYGAP, HEILAND) — from raw NMF outputs through correlation networks, community detection, and community-level summaries.

Companion artifacts:
- R package: <https://github.com/Snyder-Institute/sotk2>
- Documentation: <https://Snyder-Institute.github.io/sotk2/>
- Docker image: <https://hub.docker.com/r/thebiohub/sotk2> (bundles this app + demo data)

## Run with Docker (recommended)

The Docker image bundles the demo data and the right R environment; no local R setup needed.

```bash
docker pull thebiohub/sotk2:1.1.2
docker run --rm -p 11630:11630 thebiohub/sotk2:1.1.2
open http://localhost:11630
```

Or use the bundled launcher, which starts the container, waits for the app and opens your browser:

```bash
curl -O https://raw.githubusercontent.com/Snyder-Institute/sotk2-shiny/main/docker/launch.sh
chmod +x launch.sh
IMAGE=thebiohub/sotk2:1.1.2 ./launch.sh
```

Ctrl-C stops the container. Pin a specific version in production (`thebiohub/sotk2:1.1.2`), not `latest`.

## Run locally from source

Requirements: R >= 4.3.0, the [sotk2](https://github.com/Snyder-Institute/sotk2) package, and the CRAN packages `shiny`, `commonmark` (or `markdown`), `stringr`, `igraph`, `NMF`.

```bash
git clone https://github.com/Snyder-Institute/sotk2-shiny.git
cd sotk2-shiny
Rscript scripts/setup_data.R        # one-time: fetches demo data + builds soObj.RDS (~5 min)
Rscript -e "shiny::runApp('.', port = 11630)"
```

`setup_data.R` writes ~120 MB of `.RDS` files to `data/` (gitignored) and builds the precomputed `soObj.RDS` with the default settings expected by the app.

## Building the Docker image

The image is built from this repository (`docker/Dockerfile`, build context = repo root).

```bash
Rscript scripts/setup_data.R     # one-time: populate data/ (baked into the image)
docker/build.sh local            # native arch, --load into local docker (fast)
docker/build.sh push 1.1.2       # multi-arch (amd64 + arm64), push to Docker Hub
```

Multi-arch builds use `docker buildx` with the `sotk2-multiarch` builder. On Apple Silicon, the arm64 layer builds natively while amd64 is emulated (slower, but runs natively on x86 hosts after push).

The image contains R 4.5 ([`rocker/r-ver:4.5`](https://hub.docker.com/r/rocker/r-ver), multi-arch), `sotk2` v1.0.0 (pinned to commit `1cf8155`), its CRAN dependencies plus `shiny`, `commonmark`, `BiocManager` and `Biobase`, this app, and the demo data. Each architecture is ~860 MB.

| Tag | Points at |
|---|---|
| `1.0.0` | sotk2 R package commit `1cf8155`; ShinyApps-devel app source |
| `1.1.0` | sotk2 R package commit `1cf8155`; sotk2-shiny app source |
| `1.1.1` | As `1.1.0`; Citation card in the Overview tab now links the published manuscript |
| `1.1.2` | Always fully interactive (browse-only mode removed); Kendall removed from the correlation choices (far too slow on the demo data); Betweenness community detection fixed; Docker build moved into this repository |
| `latest` | The newest released tag |

## Repository layout

```
sotk2-shiny/
├── app.R                  # Shiny entry point
├── Rsource/
│   └── preset.R           # Defaults, color maps, helper functions
├── overview.md            # "Overview" tab content
├── interpretation.md      # "Interpretation" tab content
├── footer.html
├── ga.html                # Google Tag Manager snippet (replace with your own when forking)
├── scripts/
│   └── setup_data.R       # Fetches demo data from Zenodo + builds soObj.RDS
├── data/                  # Demo data (gitignored; populated by setup_data.R)
├── docker/
│   ├── Dockerfile
│   ├── build.sh           # buildx wrapper: local | push [version]
│   └── launch.sh          # run the image and open the browser
└── www/
    ├── css/
    ├── imgs/
    └── UsagePlot/         # Precomputed usage heatmaps (PNG) for GLASS and IVYGAP
```

## Data source

Demo data are reprocessed from publicly available cohorts (GLASS, IVYGAP, HEILAND) and deposited on Zenodo: <https://doi.org/10.5281/zenodo.18063318>.

## License

MIT. See [LICENSE](LICENSE).

## Citation

[Reproducible transcriptional modules define glioblastoma ecosystems across independent cohorts](https://doi.org/10.64898/2026.05.20.726700).
