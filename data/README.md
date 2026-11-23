# Data

The raw data are archived on [Zenodo](https://doi.org/10.5281/zenodo.24210703). This repository includes a copy of the data package so the analyses can run after cloning.

| File | Contents |
|---|---|
| [raw/students.csv](raw/students.csv) | 859 student records, with 13 original fields |
| [raw/dyads.csv](raw/dyads.csv) | 17,804 directed allocation decisions and peer nominations |
| [raw/figure2_layout.csv](raw/figure2_layout.csv) | Coordinates for the classroom drawing in Figure 2 |
| [raw/codebook.md](raw/codebook.md) | Raw-data dictionary supplied with the Zenodo package |
| [raw/null_model_order.csv](raw/null_model_order.csv) | Fixed order of the random draws used by the filter; supplied with the replication code |

Missing values are coded `NA`. Religion is recorded as `Catholic`, `Evangelical`, or `No answer`; the last category includes missing values and `N/A` and does not mean no religious affiliation.

The preparation script writes `analysis_dyads.csv` and `analysis_students.csv` in `data/generated/main/`. These files are generated locally. The [analysis dictionary](main_codebook.md) explains the added variables, and [Data and measures](../notebooks/main/01_data_and_measures.qmd) explains their construction and the filter.

The data are distributed under CC BY 4.0, as stated in the Zenodo data package. The repository's MIT license applies to the code.
