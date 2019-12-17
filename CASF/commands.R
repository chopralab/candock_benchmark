library(tidyverse)

read_files <- function(pdb, prefix = "decoy_docking_scores/") {
  print(pdb)

  pocket  <- read_tsv(paste0(prefix, pdb, "_pocket.tsv.gz"))
  protein <- read_tsv(paste0(prefix, pdb, "_protein.tsv.gz"))

  pocket$mode <- "pocket"
  protein$mode <- "protein"

  rmsd <- read_table(paste0(prefix, pdb, "_rmsd.dat"), col_names = c("name", "rmsd"), skip = 1)
  
  pocket %>% rbind(protein) %>% merge(rmsd) %>% as_tibble()
}

read_lines("coreset.lst") -> coreset

lapply(coreset, read_files) %>% bind_rows() -> all_scores

read_files_native <- function(pdb, prefix = "native_scores/") {
  print(pdb)
  
  pocket  <- read_tsv(paste0(prefix, pdb, "_pocket.tsv"))
  protein <- read_tsv(paste0(prefix, pdb, "_protein.tsv"))
  
  pocket$mode <- "pocket"
  protein$mode <- "protein"
  
  rmsd <- read_table(paste0("decoy_docking_scores/", pdb, "_rmsd.dat"), col_names = c("name", "rmsd"), skip = 1)
  
  pocket %>% rbind(protein) %>% merge(rmsd) %>% as_tibble()
}

lapply(coreset, read_files_native) %>% bind_rows() -> native_scores

all.scoring.functions <- c(quote(rmr4),  quote(rmr5),  quote(rmr6),  quote(rmr7),  quote(rmr8),  quote(rmr9),
                           quote(rmr10), quote(rmr11), quote(rmr12), quote(rmr13), quote(rmr14), quote(rmr15),
                           quote(rmc4),  quote(rmc5),  quote(rmc6),  quote(rmc7),  quote(rmc8),  quote(rmc9),
                           quote(rmc10), quote(rmc11), quote(rmc12), quote(rmc13), quote(rmc14), quote(rmc15),
                           quote(fmr4),  quote(fmr5),  quote(fmr6),  quote(fmr7),  quote(fmr8),  quote(fmr9),
                           quote(fmr10), quote(fmr11), quote(fmr12), quote(fmr13), quote(fmr14), quote(fmr15),
                           quote(fmc4),  quote(fmc5),  quote(fmc6),  quote(fmc7),  quote(fmc8),  quote(fmc9),
                           quote(fmc10), quote(fmc11), quote(fmc12), quote(fmc13), quote(fmc14), quote(fmc15),
                           quote(rcr4),  quote(rcr5),  quote(rcr6),  quote(rcr7),  quote(rcr8),  quote(rcr9),
                           quote(rcr10), quote(rcr11), quote(rcr12), quote(rcr13), quote(rcr14), quote(rcr15),
                           quote(rcc4),  quote(rcc5),  quote(rcc6),  quote(rcc7),  quote(rcc8),  quote(rcc9),
                           quote(rcc10), quote(rcc11), quote(rcc12), quote(rcc13), quote(rcc14), quote(rcc15),
                           quote(fcr4),  quote(fcr5),  quote(fcr6),  quote(fcr7),  quote(fcr8),  quote(fcr9),
                           quote(fcr10), quote(fcr11), quote(fcr12), quote(fcr13), quote(fcr14), quote(fcr15),
                           quote(fcc4),  quote(fcc5),  quote(fcc6),  quote(fcc7),  quote(fcc8),  quote(fcc9),
                           quote(fcc10), quote(fcc11), quote(fcc12), quote(fcc13), quote(fcc14), quote(fcc15)
)

sum_good <- function(all_scores, sf) {
  all_scores %>%
    group_by(pdb, mode) %>%
    mutate(selected = rank(!!sf)) %>%
    filter(rmsd < 2.0) %>%
    filter(selected == min(selected)) %>%
    select(pdb, selected, mode) %>% 
    distinct %>% group_by(mode) %>%
    summarise(sr1 = sum(selected <= 1),
              sr2 = sum(selected <= 2),
              sr3 = sum(selected <= 3),
              sr5 = sum(selected <= 5),
              sr10= sum(selected <=10),
              sr50= sum(selected <=50),
              n = n()) %>%
    mutate(sf = sf %>% as.character)
}

lapply(all.scoring.functions, function(X) {
  sum_good(all_scores %>% mutate(pdb = substr(name, 1, 4)), X)
}) %>% bind_rows() -> pure_sf_results

lapply(all.scoring.functions, function(X) {
  sum_good(native_all %>% mutate(pdb = substr(name, 1, 4)), X)
}) %>% bind_rows() -> pure_and_native_sf_results

write_scores_dir <- function(X, prefix, sf) {
  dir.create(prefix, showWarnings = F)

  for (p in unique(X$pdb)) {
    X %>%
      filter(pdb == p) %>%
      select(`#code` = name, score = !!sf) %>%
      write_tsv(paste0(prefix, "/", p, "_score.dat"))
  }
}

all_scores %>% filter(mode == "pocket") %>%
  mutate(pdb = substr(name, 1, 4)) %>%
  write_scores_dir("rmr5_docking", quote(rmr5))

all_scores %>% filter(mode == "pocket") %>%
  mutate(pdb = substr(name, 1, 4)) %>%
  write_scores_dir("rmr6_docking", quote(rmr6))

native_all_scores %>% filter(mode == "pocket") %>%
  mutate(pdb = substr(name, 1, 4)) %>%
  write_scores_dir("rmr5_native_docking", quote(rmr5))

native_all_scores %>% filter(mode == "pocket") %>%
  mutate(pdb = substr(name, 1, 4)) %>%
  write_scores_dir("rmr6_native_docking", quote(rmr6))

all_scores %>% mutate(pdb = substr(name, 1, 4)) %>%
  group_by(pdb) %>%
  filter(mode == "pocket") %>%
  filter(rmr5 == min(rmr5)) %>%
  merge(coreset.tbl) %>%
  as_tibble() -> all_scores.min_rmr5

all_scores %>% mutate(pdb = substr(name, 1, 4)) %>%
  group_by(pdb) %>%
  filter(mode == "pocket") %>%
  filter(rmr6 == min(rmr6)) %>%
  merge(coreset.tbl) %>%
  as_tibble() -> all_scores.min_rmr6

all_scores %>% mutate(pdb = substr(name, 1, 4)) %>%
  group_by(pdb) %>%
  filter(mode == "pocket") %>%
  filter(rmc15 == min(rmc15)) %>%
  merge(coreset.tbl) %>%
  as_tibble() -> all_scores.min_rmc15

all_scores %>% mutate(pdb = substr(name, 1, 4)) %>%
  group_by(pdb) %>%
  filter(mode == "pocket") %>%
  filter(rmsd == min(rmsd)) %>%
  merge(coreset.tbl) %>%
  as_tibble() -> all_scores.min_rmsd

cor_sf_with_logKa <- function(all_score, sf) {
  all_score %>%
    summarise(c = cor(!!sf, logKa)) %>%
    mutate(sf = sf %>% as.character())
}

lapply(all.scoring.functions, function(X) {
  cor_sf_with_logKa(all_scores.min_rmr5, X)
}) %>% bind_rows() -> cor.min_rmr5

lapply(all.scoring.functions, function(X) {
  cor_sf_with_logKa(all_scores.min_rmr6, X)
}) %>% bind_rows() -> cor.min_rmr6

lapply(all.scoring.functions, function(X) {
  cor_sf_with_logKa(all_scores.min_rmsd, X)
}) %>% bind_rows() -> cor.min_rmsd

all.rankers <- c(quote(rmc10), quote(rmc11), quote(rmc12),
                 quote(rmc13), quote(rmc14), quote(rmc15),
                 quote(fmc10), quote(fmc11), quote(fmc12),
                 quote(fmc13), quote(fmc14), quote(fmc15))

write_rankers <- function(all_scores, sf, prefix) {
  dir.create(prefix, showWarnings = F)
  
  all_scores %>%
    select(`#code` = pdb, score = !!sf) %>%
    write_tsv(paste0(prefix, "/", sf %>% as.character, ".tsv"))
}

lapply(all.rankers, function(X) {
  write_rankers(all_scores.min_rmr5, X, "rmr5")
})

lapply(all.rankers, function(X) {
  write_rankers(all_scores.min_rmr6, X, "rmr6")
})

lapply(all.rankers, function(X) {
  write_rankers(all_scores.min_rmsd, X, "rmsd")
})
