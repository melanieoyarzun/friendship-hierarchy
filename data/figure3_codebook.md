## Figure 3 summary tables

These tables are constructed in `code/05_figure3_cooperation.R` after loading the shared analysis data. They are saved in `output/tables/` when Figure 3 is reproduced; they are not part of the two analysis CSV files.

The directed-decision variables `tokens_sent`, `tokens_received`, `rank_gap`, and `coop_gap` retain their definitions throughout the analysis. Figure 3 also uses separate child-level and interval-level tables. Their shorter field names denote aggregates, not replacement names for the decision-level variables.

### `figure3_children_summary.csv`

One row per child, relationship group, and observed/filtered version.

| Variable | Definition |
|---|---|
| `sender_id` | Focal child's study code |
| `group` | Non-friends, mutual friends, or sender-declared one-sided friendships |
| `version` | Observed or filtered transfers |
| `gap` | Median of the child's dyadic `rank_gap` values within this relationship group |
| `sent`, `received` | Child's mean sent and received transfers in original 0–10 allocation units |
| `dif_coop` | `received - sent`: difference between the child's two means, in tokens |

For filtered transfers, the sent and received means each use their own retained allocations. `dif_coop` is finite only when both means exist. It can therefore differ from a mean of dyadic `coop_gap_filtered`, which requires both directions to be retained for each pair.

### `figure3_binned_means.csv`

One row per relationship group, observed/filtered version, and rank interval. Within a group, observed and filtered summaries use the same seven equal-width intervals of child median rank gaps.

| Variable | Definition |
|---|---|
| `group`, `version` | Relationship group and observed/filtered transfers |
| `round_gap` | Rank interval label; unrelated to the recorded game `round` |
| `median_gap` | Mean of the children's median rank gaps in the interval; the horizontal plotting position, not the interval median |
| `n` | Total number of children assigned to the interval |
| `n_with_value` | Number of children with a finite `dif_coop` |
| `mean_sent`, `mean_reci` | Means of the child-level `sent` and `received` values, omitting missing values separately |
| `sd_sent`, `sd_reci` | Standard deviations of those child-level values |
| `mean_dif_coop`, `sd_dif_coop` | Mean and standard deviation of finite child-level `dif_coop` values |
| `se_sent`, `se_reci`, `se_dif_coop` | Displayed 95% interval half-widths, already multiplied by 1.96: `1.96 * SD / sqrt(n)`. These columns are not unmultiplied standard errors |

Every child is weighted equally within an interval. With observed transfers, `mean_dif_coop = mean_reci - mean_sent`. With filtered transfers, the three means may use different valid-child sets, so this identity need not hold. The interval calculation uses the total `n`, including children without a filtered value; `n_with_value` exposes the valid-GAP support.

### `figure3_heatmap_cells.csv`

| Variable | Definition |
|---|---|
| `group` | Non-friends, mutual friends, or all asymmetric friendships, combining both nomination directions |
| `high`, `low` | Larger and smaller of the two directed transfers in a pair, each between 0 and 10 |
| `n` | Number of directed rows in the cell; each pair contributes both orientations |
| `percent` | Percentage of directed rows within the relationship group. Doubling each pair equally leaves pair percentages unchanged |
