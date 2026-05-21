# sotk2 Shiny app

Source for the [sotk2](https://github.com/Snyder-Institute/sotk2) demo Shiny app. The app provides an interactive walkthrough of the sotk2 workflow on three glioma cohorts (GLASS, IVYGAP, HEILAND) — from raw NMF outputs through correlation networks, community detection, and community-level summaries.

Companion artifacts:
- R package: <https://github.com/Snyder-Institute/sotk2>
- Documentation: <https://Snyder-Institute.github.io/sotk2/>
- Docker image: <https://hub.docker.com/r/thebiohub/sotk2> (bundles this app + demo data)
- Docker source: <https://github.com/Snyder-Institute/sotk2-docker>

## Run with Docker (recommended)

The Docker image bundles the demo data and the right R environment; no local R setup needed.

```bash
docker pull thebiohub/sotk2:latest
docker run --rm -p 11630:11630 thebiohub/sotk2:latest
open http://localhost:11630
```

Stop with `docker stop sotk2`. See [sotk2-docker](https://github.com/Snyder-Institute/sotk2-docker) for a launcher that auto-opens the browser.

## Run locally from source

Requirements: R >= 4.3.0, the [sotk2](https://github.com/Snyder-Institute/sotk2) package, and the CRAN packages `shiny`, `commonmark` (or `markdown`), `stringr`, `igraph`, `NMF`.

```bash
git clone https://github.com/Snyder-Institute/sotk2-shiny.git
cd sotk2-shiny
Rscript scripts/setup_data.R        # one-time: fetches demo data + builds soObj.RDS (~5 min)
Rscript -e "shiny::runApp('.', port = 11630)"
```

`setup_data.R` writes ~120 MB of `.RDS` files to `data/` (gitignored) and builds the precomputed `soObj.RDS` with the default settings expected by the app.

## Run modes — `SOTK2_MODE`

The app supports two runtime modes selected via the `SOTK2_MODE` environment variable:

| Mode | Behavior |
|------|----------|
| `full` (default) | Every Tutorial input is live. The user can recompute `SOSet()` and `SOTK()` with different correlation methods, datasets, thresholds, community detection algorithms, and rewiring weights. Suitable for power users on a host with adequate CPU. |
| `lite` | The app displays the precomputed `soObj.RDS` only. All recompute controls are hidden, and the underlying reactives short-circuit to the precomputed object. Display-only controls (label toggles, node size, annotation choice, cohort/community pickers) remain live. Suitable for public/open deployments. |

Examples:

```bash
SOTK2_MODE=lite Rscript -e "shiny::runApp('.', port = 11630)"
SOTK2_MODE=full Rscript -e "shiny::runApp('.', port = 11630)"
```

With Docker:

```bash
docker run --rm -p 11630:11630 -e SOTK2_MODE=full thebiohub/sotk2:latest
```

The Docker image sets `SOTK2_MODE=lite` as its default, so the public-facing experience is safe by construction. Power users override with `-e SOTK2_MODE=full`.

## Repository layout

```
sotk2-shiny/
├── app.R                  # Shiny entry point (SOTK2_MODE-aware)
├── Rsource/
│   └── preset.R           # Defaults, color maps, helper functions
├── overview.md            # "Overview" tab content
├── interpretation.md      # "Interpretation" tab content
├── footer.html
├── ga.html                # Google Tag Manager snippet (replace with your own when forking)
├── scripts/
│   └── setup_data.R       # Fetches demo data from Zenodo + builds soObj.RDS
├── data/                  # Demo data (gitignored; populated by setup_data.R)
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

If you use sotk2 in your work, please cite the associated manuscript: _to be added_.
