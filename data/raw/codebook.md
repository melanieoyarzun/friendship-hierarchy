# Codebook

All identifiers are study codes created for this release. The files contain no names or links to administrative records. Class codes follow the order of the tables in the Supporting Information, so `class_id = 16` is "Class ID 16" in Figure 2.

Files are comma-separated, UTF-8 encoded, with one header row. Missing values are coded `NA`.

## `students.csv`

One row per child (859 rows).

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
| `attendance_2017` | Attendance in the 2017 school year (%); used in SI Table S1 |
| `guardian_secondary` | 1 = guardian completed secondary education, or has any technical or higher education |
| `guardian_education` | Guardian education in four levels: `1 Primary or less` (including no schooling), `2 Secondary incomplete`, `3 Secondary complete`, `4 Tertiary` (any technical-professional or higher education), as in SI Table S9 and Figure S8 |
| `repeated_grade` | 1 = the child repeated a grade, 0 = never; missing when not recorded (249 children) |
| `religion` | Recorded religion: `Catholic` (373), `Evangelical` (341), or `No answer` (145). Source `Católica` and `Evangélica` are translated; missing source values and `N/A` are grouped as `No answer`, as in SI Table S9 and Figure S8. `No answer` does not imply no religious affiliation |

## `dyads.csv`

One row per directed decision (17,804 rows).

| Variable | Description |
|---|---|
| `class_id` | Classroom |
| `round` | Classroom round in which the pair played |
| `sender_id` | Child who decides |
| `receiver_id` | Partner who receives |
| `tokens_sent` | Tokens (0–10) allocated by sender $i$ to partner $j$, denoted $w_{ij}$ in the paper. Recorded before the game multiplier (tokens given were doubled for the receiver) |
| `seconds_since_start` | Seconds between the start of the class session and this decision. Missing in 16 classrooms where the tablets did not record the time of each decision |
| `nom_q1` … `nom_q9` | 1 if the sender named the receiver in nomination question *k* |

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

## `figure2_layout.csv`

Node positions for the classroom drawing in Figure 2 (9 rows).

| Variable | Description |
|---|---|
| `student_id` | Study code of a child in class 16 |
| `x`, `y` | Position of the child in the drawing (scaled to −1…1) |

These coordinates are used only for plotting.
