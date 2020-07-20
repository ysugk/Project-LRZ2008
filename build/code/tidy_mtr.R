rm(list = ls())

library(tidyverse)

mtr <- read_delim("build/input/JG/mtr8018.dat",
                  delim = " ",
                  col_names = c("cnum", "fyear", "mtrbi", "mtrai", "permno", "gvkey"),
                  na = ".")

write_rds(mtr, "build/output/mtr8018.rds", compress = "gz")
