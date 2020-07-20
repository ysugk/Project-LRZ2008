library(tidyverse)

df <- read_csv("build/input/bea.gov/sec1.tab1.1.9.csv", skip = 4)

fyear <- names(df)[3:93] %>%
  as.numeric()
gdpdeflator <- df[2, 3:93] %>%
  as.numeric()

df <- tibble(fyear, gdpdeflator) 

write_rds(df, "build/output/gdpdeflator.rds", compress = "gz")
