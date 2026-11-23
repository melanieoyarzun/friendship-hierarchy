# Data for "Friendship Modulates the Expression of Hierarchy in Cooperation"

Melanie Oyarzun, Carlos Rodriguez-Sickert and Cristian Candia

This record contains the pseudonymized raw data of the study. 859 children in 45 classrooms of 14 Chilean primary schools (grades 3 to 5) played a social-dilemma game with classmates and answered nine peer-nomination questions.

## Files

| File | Rows | Contents |
|---|---|---|
| `students.csv` | 859 | One row per child: classroom, school, grade, sex, age, GPA, attendance, guardian education, grade repetition, and religion |
| `dyads.csv` | 17,804 | One row per directed decision: tokens sent to a classmate and the sender's nominations of that classmate |
| `figure2_layout.csv` | 9 | Drawing coordinates for the classroom shown in Figure 2 |
| `codebook.md` | | Description of every variable |

Identifiers are study codes created for this release; the files contain no names or links to administrative records. Missing values are coded `NA`.

Religion is coded as `Catholic`, `Evangelical`, or `No answer`. The last category includes missing source values and `N/A`, following the Supporting Information; it is not a category for no religious affiliation.

## Reproducing the results

The analysis datasets (Social Rank, Cooperation GAP, friendship types and the null-model filter) are not included here: they are built from these files by the replication code. The replication package, with the R scripts, notebooks, instructions and the fixed order of the random shuffles used by the null-model filter, is archived separately and linked from this record's related works.

## License

CC BY 4.0. Please cite the article and this dataset.
