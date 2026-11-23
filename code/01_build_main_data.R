# Main-result data: paired transfers, friendship, Social Rank, and the null-model filter.
# Run from the repository root: Rscript code/01_build_main_data.R
# Writes data/generated/main/analysis_dyads.csv and analysis_students.csv.
# The student file adds only pagerank, social_rank, and attendance_z to the raw records.

## ---- packages ----
library(tidyverse)
library(igraph)
library(here)


## ---- read-data ----
dyads    <- read_csv(here("data", "raw", "dyads.csv"),    show_col_types = FALSE)
students <- read_csv(here("data", "raw", "students.csv"), show_col_types = FALSE)


## ---- display-data ----
cat("Directed decisions:", format(nrow(dyads), big.mark = ","), "\n")   # 17,804
cat("Children:          ", nrow(students), "\n")                         # 859
cat("Classrooms:        ", n_distinct(dyads$class_id), "\n")             # 45


## ---- tokens-received ----
# Each row is one decision: sender i gives `tokens_sent` (0 to 10) to receiver j.
# In the same round, j also decided how much to give to i. That reverse
# decision is what i receives. We find it by swapping sender and receiver.

reverse_decisions <- dyads %>%
  select(class_id,
         sender_id   = receiver_id,
         receiver_id = sender_id,
         tokens_received = tokens_sent,
         round_reverse = round)

dyads <- dyads %>%
  left_join(reverse_decisions, by = c("class_id", "sender_id", "receiver_id"))

# every decision has its reverse, and both happened in the same round
stopifnot(!anyNA(dyads$tokens_received))
stopifnot(all(dyads$round == dyads$round_reverse))

dyads <- dyads %>% select(-round_reverse)


## ---- cooperation-gap ----
# Cooperation GAP (from the sender's point of view): what i receives minus what
# i sends. Positive values mean i receives more than i gives.

dyads <- dyads %>%
  mutate(coop_gap = tokens_received - tokens_sent)


## ---- friendship-type ----
# Question 3: "Select 2-5 classmates you consider your best friends".
# nom_q3 = 1 if the sender named the receiver. To know if the receiver also
# named the sender, we look at the reverse row, as we did with the tokens.

reverse_friend <- dyads %>%
  select(class_id,
         sender_id   = receiver_id,
         receiver_id = sender_id,
         friend_reverse = nom_q3)

dyads <- dyads %>%
  left_join(reverse_friend, by = c("class_id", "sender_id", "receiver_id")) %>%
  mutate(friendship = case_when(
    nom_q3 == 1 & friend_reverse == 1 ~ "Mutual",
    nom_q3 == 1 & friend_reverse == 0 ~ "Sender declares",    # one-sided, i named j
    nom_q3 == 0 & friend_reverse == 1 ~ "Receiver declares",  # one-sided, j named i
    nom_q3 == 0 & friend_reverse == 0 ~ "Non-friends"
  ))

cat("Decisions by friendship type:\n")
dyads %>% count(friendship) %>% mutate(percent = round(100 * n / sum(n), 2))


## ---- popularity-network ----
# Questions 4 and 5: "most popular and well-known" and "not popular or
# well-known". For every ordered pair (i, j) in a classroom:
#
#     s_ij = nom_q4 - nom_q5      +1 popular, -1 not popular, 0 not named
#     a_ij = s_ij + 1             weights 2, 0 and 1 (all non-negative)
#
# a_ij is the weight of the edge i -> j in the popularity network.

popularity_edges <- dyads %>%
  transmute(class_id,
            from = as.character(sender_id),
            to   = as.character(receiver_id),
            weight = nom_q4 - nom_q5 + 1)

cat("Edges of the popularity network by weight (2 popular, 0 not popular, 1 not named):\n")
count(popularity_edges, weight)


## ---- pagerank ----
# PageRank (damping 0.85) is computed separately in each classroom.
# We then rescale it within each classroom to go from 0 (lowest rank in the
# class) to 1 (highest rank in the class). This is our Social Rank.

pagerank_one_class <- function(edges_one_class) {
  network <- graph_from_data_frame(edges_one_class %>% select(from, to, weight),
                                   directed = TRUE)
  pr <- page_rank(network, damping = 0.85, directed = TRUE)$vector   # uses edge weights
  tibble(student_id = as.numeric(names(pr)), pagerank = pr)
}

social_rank <- popularity_edges %>%
  group_by(class_id) %>%
  group_modify(~ pagerank_one_class(.x)) %>%
  mutate(social_rank = (pagerank - min(pagerank)) / (max(pagerank) - min(pagerank))) %>%
  ungroup()

students <- students %>%
  left_join(social_rank %>% select(student_id, pagerank, social_rank),
            by = "student_id")

cat("Social Rank (0 to 1 within each classroom):\n")
summary(social_rank$social_rank)


## ---- rank-gap ----
# Social Rank GAP of a decision = sender's rank - receiver's rank.
# Positive: the sender has higher rank. It goes from -1 to 1.

dyads <- dyads %>%
  left_join(social_rank %>% select(sender_id = student_id, sender_rank = social_rank),
            by = "sender_id") %>%
  left_join(social_rank %>% select(receiver_id = student_id, receiver_rank = social_rank),
            by = "receiver_id") %>%
  mutate(rank_gap = sender_rank - receiver_rank,
         # round away floating-point noise, so that two children with the
         # same rank have a gap of exactly 0 (and not 1e-16)
         rank_gap = round(rank_gap, 10))

cat("Social Rank GAP (sender - receiver):\n")
summary(dyads$rank_gap)


## ---- main-student-covariates ----
# Figure 1D uses attendance standardized within classroom and GPA in its raw scale.
students <- students %>%
  group_by(class_id) %>%
  mutate(attendance_z = (attendance - mean(attendance, na.rm = TRUE)) /
                         sd(attendance, na.rm = TRUE)) %>%
  ungroup()


## ---- filter-settings ----
n_shuffles <- 1000
null_seed <- 109
retention <- 0.50


## ---- null-model-score ----
# Null-model filtering of the directed token transfers.
#
# Stage 1. In each classroom we write the token exchanges as a matrix: one row
# per sender, one column per receiver. For each sender we shuffle her row
# 1,000 times: the same allocations (zeros included) go to her classmates in a
# random order, so her total and her full 0-10 profile are kept and only *who*
# receives each amount changes. Each shuffle gives a simulated value to every
# cell i -> j. The 1,000 simulated values of a cell are its null distribution;
# we keep their mean and standard deviation, and score the observed transfer by
# how far it is from that mean, in standard deviations:
#
#     d_ij = | tokens_sent_ij - null_mean_ij | / null_sd_ij     (0 if null_sd_ij = 0)
#
# The draws are random, so the seed is fixed (109). The shuffles are drawn
# classroom by classroom and child by child, in the order given in
# data/raw/null_model_order.csv. The seed and this fixed sequence determine
# the simulation reproducibly.


null_model_order <- read_csv(here("data", "raw", "null_model_order.csv"), show_col_types = FALSE)

simulate_one_class <- function(class_dyads, class_order) {
  # children in the supplied simulation order
  ids <- class_order %>% arrange(null_model_child_order) %>% pull(student_id)

  # matrix of tokens sent: row = sender, column = receiver
  tokens <- matrix(0, length(ids), length(ids))
  tokens[cbind(match(class_dyads$sender_id, ids), match(class_dyads$receiver_id, ids))] <-
    class_dyads$tokens_sent

  map_dfr(seq_along(ids), function(i) {
    others <- seq_along(ids)[-i]          # classmates, without the diagonal
    row    <- tokens[i, others]           # what child i gave to each of them

    # one column per shuffle: row i with its values in a random order
    shuffles <- matrix(replicate(n_shuffles, row[sample.int(length(row))]), nrow = length(row))

    tibble(sender_id   = ids[i],
           receiver_id = ids[others],
           null_mean   = rowMeans(shuffles),        # mean of the simulated values of each cell
           null_sd     = apply(shuffles, 1, sd))    # their standard deviation
  })
}

set.seed(null_seed)
null_model <- null_model_order %>%
  distinct(class_id, null_model_class_order) %>%
  arrange(null_model_class_order) %>%
  pull(class_id) %>%
  map_dfr(function(cl) {
    simulate_one_class(dyads %>% filter(class_id == cl),
                       null_model_order %>% filter(class_id == cl))
  })

dyads <- dyads %>%
  left_join(null_model, by = c("sender_id", "receiver_id")) %>%
  mutate(departure = if_else(null_sd > 0, abs(tokens_sent - null_mean) / null_sd, 0))

cat("Null model: shuffles per sender:", n_shuffles, "| seed:", null_seed, "\n")
cat("Senders who give the same amount to everyone (score 0 for all their transfers):",
    n_distinct(dyads$sender_id[dyads$null_sd == 0]), "\n")


## ---- null-model-filter ----
# Stage 2. Keep the 50% of all directed transfers with the largest departure
# (one common cutoff for the whole sample). Dropped transfers become NA, not 0,
# because 0 is a real decision in the game.
# Stage 3. A dyad enters the filtered Cooperation GAP only if BOTH directions
# are kept.

cutoff <- sort(dyads$departure, decreasing = TRUE)[ceiling(retention * nrow(dyads))]

reverse_departure <- dyads %>%
  select(class_id,
         sender_id   = receiver_id,
         receiver_id = sender_id,
         departure_reverse = departure)

dyads <- dyads %>%
  left_join(reverse_departure, by = c("class_id", "sender_id", "receiver_id")) %>%
  mutate(
    tokens_sent_filtered     = if_else(departure >= cutoff,         tokens_sent,     NA_real_),
    tokens_received_filtered = if_else(departure_reverse >= cutoff, tokens_received, NA_real_),
    coop_gap_filtered        = tokens_received_filtered - tokens_sent_filtered
  ) %>%
  select(-departure_reverse)

cat(sprintf("Share of transfers kept:                     %.3f\n",
            mean(!is.na(dyads$tokens_sent_filtered))))   # about 0.50
cat(sprintf("Share of decisions with both directions kept: %.3f\n",
            mean(!is.na(dyads$coop_gap_filtered))))      # about 0.26


## ---- save ----
dir.create(here("data", "generated", "main"), recursive = TRUE, showWarnings = FALSE)

analysis_dyads <- dyads %>%
  select(class_id, round, sender_id, receiver_id,
         tokens_sent, tokens_received, coop_gap,
         friendship, sender_rank, receiver_rank, rank_gap,
         null_mean, null_sd, departure,
         tokens_sent_filtered, tokens_received_filtered, coop_gap_filtered,
         seconds_since_start, starts_with("nom_q"))
analysis_students <- students

write_csv(analysis_dyads, here("data", "generated", "main", "analysis_dyads.csv"))
write_csv(analysis_students, here("data", "generated", "main", "analysis_students.csv"))
dyads <- analysis_dyads
students <- analysis_students


