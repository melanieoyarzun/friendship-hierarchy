# Replication companion website

The [published site](https://melanieoyarzun.github.io/friendship-hierarchy/) opens with the study overview, Figure 1, and the sidebar for the main results and Supporting Information. The raw data are archived on [Zenodo](https://doi.org/10.5281/zenodo.24210703).

`notebooks/index.qmd` is the single homepage. `notebooks/_quarto.yml` defines the shared navigation and renders the complete site. This folder stages those pages for publication; it does not maintain a second homepage.

## Build locally

From the repository root:

```sh
Rscript code/run_all.R
quarto render notebooks --profile ipynb --to ipynb
quarto render notebooks
python3 website/build_site.py
```

Open `website/_site/index.html`, or use `quarto preview notebooks` for a local preview. The [setup instructions](../README.md#build-the-notebook-viewer-and-jupyter-files) list the required software. Python 3.9 or later is used for staging. The publication layout uses the latest reproduced Figure 3 assembly when it is available. Earlier `/analysis/` page URLs redirect to their corresponding pages in the unified site.

GitHub Actions runs the same commands when code, notebooks, or input data are pushed. It reproduces the results, rebuilds the Jupyter downloads and HTML pages, and publishes the site from the default branch. Tables and figures can also be downloaded from the workflow's `replication-results` artifact for 30 days. The workflow does not create commits; the Jupyter files in the repository reflect the versions committed locally.
