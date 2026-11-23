# Notebooks

**Friendship Modulates the Expression of Hierarchy in Cooperation** Melanie Oyarzun, Carlos Rodriguez-Sickert, Cristian Candia

Each Quarto source (`.qmd`) is paired with a Jupyter notebook (`.ipynb`) containing R code and precomputed outputs. Each notebook explains the corresponding scripts in `../code/`.

## Main text

1. [Data and measures](main/01_data_and_measures.ipynb) — Inputs, variable definitions, Social Rank normalization, null-model filtering, and the full data dictionary.
2. [Table 1: main models](main/02_table1_main_models.ipynb) — Five regression samples, fixed effects, effect sizes, and the pooled friendship interaction.
3. [Figure 1D: partner assignment](main/03_figure1_partner_assignment.ipynb) — Centered assigned partner rank and the balance check.
4. [Figure 2: classroom networks](main/04_figure2_classroom_networks.ipynb) — Friendship, popularity, non-popularity, and game transfers in one classroom.
5. [Figure 3](#figure-3) — Exchange patterns (A), tokens by rank (B), the Cooperation GAP (C), and the complete nine-panel assembly. The four notebooks are listed below.
6. [Numbers in the main text](main/08_numbers_in_text.ipynb) — Sample and design counts, quartile comparisons, filtered models, and other cited quantities.

## Figure 3

The website [Figure 3 index](main/figure3_index.qmd) groups the four pages:

- [A · Exchange patterns](main/05_figure3a_exchange_patterns.ipynb)
- [B · Tokens by rank](main/06_figure3b_tokens_by_rank.ipynb)
- [C · Cooperation GAP](main/07_figure3c_cooperation_gap.ipynb)
- [Complete assembly](main/figure3_assembly.ipynb)

B and C first draw the non-friend example with explicit graph code, then show the reusable function and the other relationship groups.

## Supporting Information

- [S1 · Study design and data description](si/S1_study_design.ipynb)
- [S2 · Peer-nomination survey](si/S2_nomination_survey.ipynb)

## Running the notebooks

The notebooks use the R kernel for Jupyter ([IRkernel](https://irkernel.github.io)). `main/01_data_and_measures.ipynb` builds the shared data from the raw files and explains each preparation step and the filter. Only its final step saves `analysis_dyads.csv` and `analysis_students.csv` in `data/generated/main/`. The result notebooks reuse these objects if available in R, otherwise read the saved files, and build missing inputs on first use. Figure 3 creates its own plotting summaries after loading the shared data. The supplementary notebooks use the same prepared data. Each notebook runs independently. Paths are resolved with the **here** package.

## Quarto viewer and exports

After installing the [build dependencies](../README.md#build-the-notebook-viewer-and-jupyter-files), run these commands from the repository root.

```sh
quarto preview notebooks
```

The viewer opens in a browser with a sidebar for Main Results and Supporting Information. To export the Jupyter notebooks from the same sources, run the following command.

```sh
quarto render notebooks --profile ipynb --to ipynb
```
