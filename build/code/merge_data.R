rm(list = ls())

library(tidyverse)
library(labelled)

funda <- read_rds("build/input/wrds/funda.rds")
mtr <- read_rds("build/output/mtr8018.rds")
gdpdeflator <- read_rds("build/output/gdpdeflator.rds")

df <- funda %>%
  left_join(mtr, by = c("fyear", "gvkey")) %>%
  left_join(gdpdeflator, by = "fyear")

var_label(df) <- list(mtrbi = "marginal tax rate before interest expense",
                      mtrai = "marginal tax rate after interest expense",
                      gdpdeflator = "GDP deflator from bea.gov")

haven::write_dta(df, "build/output/data.dta")
