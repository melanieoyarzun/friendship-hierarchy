# Data dictionary {#data-dictionary}

Identifiers are study codes. The following fields cover the raw inputs and shared analysis data used in the main-result notebooks.

## Raw data

### `students.csv` 

#####  one row per child (859 rows)

| Variable | Description |
|---|---|
| `student_id` | Study code of the child |
| `class_id` | Classroom (1–45) |
| `school_id` | School (1–14) |
| `grade` | Grade level (3, 4 or 5, Chilean primary school) |
| `female` | 1 = girl, 0 = boy |
| `age` | Age in years on the day of the experiment (one decimal) |
| `gpa` | Grade point average, Chilean 1–7 scale |
| `attendance` | Attendance in the previous semester (% of school days); used in the balance tests |
| `attendance_2017` | Attendance in the 2017 school year (%); recorded as a separate attendance measure |
| `guardian_secondary` | 1 = guardian completed secondary education, or has any technical or higher education |
| `guardian_education` | Guardian education in four levels: `1 Primary or less` (including no schooling), `2 Secondary incomplete`, `3 Secondary complete`, `4 Tertiary` (any technical-professional or higher education), as in SI Table S9 and Figure S8 |
| `repeated_grade` | 1 = the child repeated a grade, 0 = never; missing when not recorded (249 children) |
| `religion` | Recorded religion: `Catholic` (373), `Evangelical` (341), or `No answer` (145). Source `Católica` and `Evangélica` are translated; missing source values and `N/A` are grouped as `No answer`, as in SI Table S9 and Figure S8. `No answer` does not imply no religious affiliation |

### `dyads.csv` 

##### one row per directed decision (17,804 rows)

| Variable | Description |
|---|---|
| `class_id` | Classroom |
| `round` | Classroom round in which the pair played |
| `sender_id` | Child who decides |
| `receiver_id` | Partner who receives |
| `tokens_sent` | Tokens (0–10) allocated by sender $i$ to partner $j$, denoted $w_{ij}$ in the paper. Recorded before the game multiplier |
| `seconds_since_start` | Seconds between the start of the class session and this decision. Missing in 16 classrooms where the tablets did not record the time of each decision |
| `nom_q1` … `nom_q9` | 1 if the sender named the receiver in nomination question *k* |

### `null_model_order.csv`

##### one row per child (859 rows)

Fixed sequence in which the null-model filter visits classrooms and children when drawing random shuffles. This sequence and seed 109 determine the simulated values reproducibly. These ordering fields are used for simulation, not as explanatory variables.

| Variable | Description |
|---|---|
| `class_id` | Classroom |
| `student_id` | Study code of the child |
| `null_model_class_order` | Position of the classroom in the order of the shuffles (1–45) |
| `null_model_child_order` | Position of the child within her classroom |

Nomination questions (each child named 2 to 5 classmates):

1. would most like to hang out with
2. would least like to hang out with
3. **best friends** (defines friendship type)
4. **most popular and well-known** (Social Rank, positive)
5. **not popular or well-known** (Social Rank, negative)
6. start fights
7. make fun of others
8. are kind to others
9. cooperate

### `figure2_layout.csv` 

##### node positions for the assembled Figure 2 (9 rows)

| Variable | Description |
|---|---|
| `student_id` | Study code of a child in class 16 |
| `x`, `y` | Position of the child in the paper's drawing of Figure 2 (scaled to −1…1) |

These coordinates reproduce the drawing in Figure 2 and are used only for plotting.

## Prepared main-result data

The files in `data/generated/main/` retain the raw fields and add the measures below. Each directed decision remains a row; each child remains a row in the student file.

| File | Added field | Meaning |
|---|---|---|
| `analysis_students.csv` | `pagerank` | Popularity-network PageRank within classroom, damping 0.85 |
| | `social_rank` | PageRank rescaled to 0–1 within classroom |
| | `attendance_z` | Attendance z-score within classroom, used in Figure 1D |
| `analysis_dyads.csv` | `tokens_received` | Partner's allocation in the reverse decision, 0–10 tokens before the game multiplier |
| | `coop_gap` | `tokens_received - tokens_sent`, from −10 to 10 tokens |
| | `friendship` | Mutual, non-friends, sender declares, or receiver declares |
| | `sender_rank`, `receiver_rank` | Each child's normalized Social Rank |
| | `rank_gap` | `sender_rank - receiver_rank`, from −1 to 1, rounded to ten decimals |
| | `null_mean`, `null_sd` | Mean and SD of the transfer's 1,000 simulated values |
| | `departure` | Absolute distance from the null mean divided by null SD; zero when the SD is zero |
| | `tokens_sent_filtered`, `tokens_received_filtered` | Transfers passing the global 50% departure cutoff in their respective directions; excluded values are missing |
| | `coop_gap_filtered` | Received minus sent when both directions pass the filter |

The token variables and Cooperation GAP are not normalized. Social Rank is normalized before forming the rank gap. The filter changes which transfers contribute to a filtered quantity; it leaves the observed variables intact.

## Graph edge attributes

Graph constructors use the conventional edge attribute `weight`. In the popularity graph it is $a_{ij}=P^+_{ij}-P^-_{ij}+1$, with values 0, 1, or 2. In a game-transfer graph it is a copy of `tokens_sent`. Its meaning follows the graph being constructed; it does not replace the token variable in the analysis datasets.
