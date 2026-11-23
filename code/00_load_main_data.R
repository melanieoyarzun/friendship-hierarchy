# Load the prepared main-result data, or build them on first use.
# Keep analysis_dyads and analysis_students unchanged; each analysis works on a copy.

main_data_dir <- here::here("data", "generated", "main")
main_dyads_file <- file.path(main_data_dir, "analysis_dyads.csv")
main_students_file <- file.path(main_data_dir, "analysis_students.csv")

main_dyad_fields <- c("class_id", "round", "sender_id", "receiver_id", "tokens_sent",
                     "tokens_received", "coop_gap", "friendship", "sender_rank",
                     "receiver_rank", "rank_gap", "null_mean", "null_sd", "departure",
                     "tokens_sent_filtered", "tokens_received_filtered", "coop_gap_filtered",
                     "seconds_since_start", paste0("nom_q", 1:9))
main_student_fields <- c("student_id", "class_id", "school_id", "female", "age", "gpa",
                        "attendance", "religion", "pagerank", "social_rank", "attendance_z")

main_data_in_memory <- exists("analysis_dyads", inherits = TRUE) &&
  exists("analysis_students", inherits = TRUE) &&
  all(main_dyad_fields %in% names(analysis_dyads)) &&
  all(main_student_fields %in% names(analysis_students))

main_data_source <- "R session"
if (!main_data_in_memory) {
  if (file.exists(main_dyads_file) && file.exists(main_students_file)) {
    analysis_dyads <- readr::read_csv(main_dyads_file, show_col_types = FALSE)
    analysis_students <- readr::read_csv(main_students_file, show_col_types = FALSE)
    main_data_source <- "Saved CSV files"
  } else {
    source(here::here("code", "01_build_main_data.R"), local = TRUE)
    main_data_source <- "Built from raw data"
  }
}

if (!all(main_dyad_fields %in% names(analysis_dyads)) ||
    !all(main_student_fields %in% names(analysis_students))) {
  stop("The main analysis data are incomplete. Rebuild with: Rscript code/01_build_main_data.R",
       call. = FALSE)
}

main_data_status <- tibble::tibble(
  dataset = c("analysis_dyads", "analysis_students"),
  rows = c(nrow(analysis_dyads), nrow(analysis_students)),
  source = main_data_source
)

dir.create(here::here("output", "tables"), recursive = TRUE, showWarnings = FALSE)
dir.create(here::here("output", "figures"), recursive = TRUE, showWarnings = FALSE)
