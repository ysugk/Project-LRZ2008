rm(list = ls())
setwd("~/Projects/Replication/LRZ2008")

library(tidyverse)
library(ystools)
library(glue)
library(lfe)

data <- haven::read_dta("analysis/input/prepared.dta") %>%
  mutate(logsale = xtlag(logsale, 1, gvkey, fyear, 1),
         mtb = xtlag(mtb, 1, gvkey, fyear, 1),
         prof = xtlag(prof, 1, gvkey, fyear, 1),
         tang = xtlag(tang, 1, gvkey, fyear, 1),
         indblev = xtlag(indblev, 1, gvkey, fyear, 1),
         cfvol = xtlag(cfvol, 1, gvkey, fyear, 1),
         divpayer = xtlag(divpayer, 1, gvkey, fyear, 1))

set.seed(20200708)

decompose_variance <- function(y, X, fe){

  k1 <- length(fe)
  k2 <- length(X)

  rss_ls <- vector(mode = "numeric", length = k1 + k2)

  if (k1 == 1 & k2 == 0){
    if_else(is_empty(fe),
            fe_eq <- "0",
            fe_eq <- paste0(fe, collapse = "+"))

    eq <- if_else(is_empty(X),
                  eq <- glue(y, "~0|", fe_eq),
                  eq <- glue(y, "~", paste0(X, collapse = "+"), "|", fe_eq))

    m <- felm(formula = formula(eq), data = data_sample)

    resid <- m$residuals
    rss <- sum(resid^2)
    fitted <- m$fitted.values
    tss <- sum((fitted + resid - mean(fitted + resid))^2)
    r2adj <- 1 - (rss/(m$df))/(tss/(m$N - 1))

    ss <- 1

    return(c(ss, r2adj))
  }


  for(i in 1:k1){
    fe_eq <- if_else(is_empty(fe[-i]),
                     "0",
                     paste0(fe[-i], collapse = "+"))

    eq <- if_else(is_empty(X),
                  glue(y, "~0|", fe_eq),
                  glue(y, "~", paste0(X, collapse = "+"), "|", fe_eq))

    m <- felm(formula = formula(eq), data = data_sample)
    resid <- m$residuals
    rss <- sum(resid^2)

    rss_ls[i] <- rss
  }

  if (k2 != 0){
    for(i in 1:k2){
      if_else(is_empty(fe),
              fe_eq <- "0",
              fe_eq <- paste0(fe, collapse = "+"))

      eq <- if_else(is_empty(X[-i]),
                    eq <- glue(y, "0|", fe_eq),
                    eq <- glue(y, "~", paste0(X[-i], collapse = "+"), "|", fe_eq))

      m <- felm(formula = formula(eq), data = data_sample)
      resid <- m$residuals
      rss <- sum(resid^2)

      rss_ls[k1 + i] <- rss
    }
  }

  if_else(is_empty(fe),
          fe_eq <- "0",
          fe_eq <- paste0(fe, collapse = "+"))

  eq <- if_else(is_empty(X),
                eq <- glue(y, "~0|", fe_eq),
                eq <- glue(y, "~", paste0(X, collapse = "+"), "|", fe_eq))

  m <- felm(formula = formula(eq), data = data_sample)

  resid <- m$residuals
  rss <- sum(resid^2)
  fitted <- m$fitted.values
  tss <- sum((fitted + resid - mean(fitted + resid))^2)
  r2adj <- 1 - (rss/(m$df))/(tss/(m$N - 1))

  ss <- vector("numeric", k1 + k2)

  for(i in 1:(k1 + k2)){
    ss[i] <- rss_ls[i] - rss
  }

  ss <- ss/sum(ss)

  c(ss, r2adj)
}

# Book Leverage: column (a) ------
y <- "blev"
X <- NULL
fe <- c("gvkey")

df <- matrix(nrow = length(X) + length(fe) + 1, ncol = 100)

for (i in 1:100){
  cat(i, "th Simulation\n")

  gvkey_sample <- data %>%
    distinct(gvkey) %>%
    sample_frac(0.1, replace = FALSE)

  data_sample <- data %>%
    semi_join(gvkey_sample, by = "gvkey")

  df[ ,i] <- decompose_variance(y, X, fe)
}

col_a <- apply(df, 1, mean)
names(col_a) <- c(fe, X, "adjr2")

# Book Leverage: column (b) ------
X <- NULL
fe <- c("fyear")

df <- matrix(nrow = length(X) + length(fe) + 1, ncol = 100)

for (i in 1:100){
  cat(i, "th Simulation\n")

  gvkey_sample <- data %>%
    distinct(gvkey) %>%
    sample_frac(0.1, replace = FALSE)

  data_sample <- data %>%
    semi_join(gvkey_sample, by = "gvkey")

  df[ ,i] <- decompose_variance(y, X, fe)
}

col_b <- apply(df, 1, mean)
names(col_b) <- c(fe, X, "adjr2")

# Book Leverage: column (c) ------
X <- NULL
fe <- c("gvkey", "fyear")

df <- matrix(nrow = length(X) + length(fe) + 1, ncol = 100)

for (i in 1:100){
  cat(i, "th Simulation\n")

  gvkey_sample <- data %>%
    distinct(gvkey) %>%
    sample_frac(0.1, replace = FALSE)

  data_sample <- data %>%
    semi_join(gvkey_sample, by = "gvkey")

  df[ ,i] <- decompose_variance(y, X, fe)
}

col_c <- apply(df, 1, mean)
names(col_c) <- c(fe, X, "adjr2")

# Book Leverage: column (d) ------
X <- c("logsale", "mtb", "prof", "tang")
fe <- c("fyear", "ffind")

df <- matrix(nrow = length(X) + length(fe) + 1, ncol = 100)

for (i in 1:100){
  cat(i, "th Simulation\n")

  gvkey_sample <- data %>%
    distinct(gvkey) %>%
    sample_frac(0.1, replace = FALSE)

  data_sample <- data %>%
    semi_join(gvkey_sample, by = "gvkey")

  df[ ,i] <- decompose_variance(y, X, fe)
}

col_d <- apply(df, 1, mean)
names(col_d) <- c(fe, X, "adjr2")

# Book Leverage: column (e) ------
X <- c("logsale", "mtb", "prof", "tang")
fe <- c("gvkey", "fyear")

df <- matrix(nrow = length(X) + length(fe) + 1, ncol = 100)

for (i in 1:100){
  cat(i, "th Simulation\n")

  gvkey_sample <- data %>%
    distinct(gvkey) %>%
    sample_frac(0.1, replace = FALSE)

  data_sample <- data %>%
    semi_join(gvkey_sample, by = "gvkey")

  df[ ,i] <- decompose_variance(y, X, fe)
}

col_e <- apply(df, 1, mean)
names(col_e) <- c(fe, X, "adjr2")

# Book Leverage: column (f) ------
X <- c("logsale", "mtb", "prof", "tang", "indblev", "cfvol", "divpayer")
fe <- c("fyear", "ffind")

df <- matrix(nrow = length(X) + length(fe) + 1, ncol = 100)

for (i in 1:100){
  cat(i, "th Simulation\n")

  gvkey_sample <- data %>%
    distinct(gvkey) %>%
    sample_frac(0.1, replace = FALSE)

  data_sample <- data %>%
    semi_join(gvkey_sample, by = "gvkey")

  df[ ,i] <- decompose_variance(y, X, fe)
}

col_f <- apply(df, 1, mean)
names(col_f) <- c(fe, X, "adjr2")

# Book Leverage: column (g) ------
X <- c("logsale", "mtb", "prof", "tang", "indblev", "cfvol", "divpayer")
fe <- c("gvkey", "fyear")

df <- matrix(nrow = length(X) + length(fe) + 1, ncol = 100)

for (i in 1:100){
  cat(i, "th Simulation\n")

  gvkey_sample <- data %>%
    distinct(gvkey) %>%
    sample_frac(0.1, replace = FALSE)

  data_sample <- data %>%
    semi_join(gvkey_sample, by = "gvkey")

  df[ ,i] <- decompose_variance(y, X, fe)
}

col_g <- apply(df, 1, mean)
names(col_g) <- c(fe, X, "adjr2")

blev_tab <- bind_rows(col_a, col_b, col_c, col_d, col_e, col_f, col_g) %>%
  select(gvkey, fyear, logsale, mtb, prof, tang, indblev, cfvol, divpayer, ffind, adjr2) %>%
  as.matrix() %>%
  t()

# Market Leverage: column (a) ------
y <- "mlev"
X <- NULL
fe <- c("gvkey")

df <- matrix(nrow = length(X) + length(fe) + 1, ncol = 100)

for (i in 1:100){
  cat(i, "th Simulation\n")

  gvkey_sample <- data %>%
    distinct(gvkey) %>%
    sample_frac(0.1, replace = FALSE)

  data_sample <- data %>%
    semi_join(gvkey_sample, by = "gvkey")

  df[ ,i] <- decompose_variance(y, X, fe)
}

col_a <- apply(df, 1, mean)
names(col_a) <- c(fe, X, "adjr2")

# Market Leverage: column (b) ------
X <- NULL
fe <- c("fyear")

df <- matrix(nrow = length(X) + length(fe) + 1, ncol = 100)

for (i in 1:100){
  cat(i, "th Simulation\n")

  gvkey_sample <- data %>%
    distinct(gvkey) %>%
    sample_frac(0.1, replace = FALSE)

  data_sample <- data %>%
    semi_join(gvkey_sample, by = "gvkey")

  df[ ,i] <- decompose_variance(y, X, fe)
}

col_b <- apply(df, 1, mean)
names(col_b) <- c(fe, X, "adjr2")

# Market Leverage: column (c) ------
X <- NULL
fe <- c("gvkey", "fyear")

df <- matrix(nrow = length(X) + length(fe) + 1, ncol = 100)

for (i in 1:100){
  cat(i, "th Simulation\n")

  gvkey_sample <- data %>%
    distinct(gvkey) %>%
    sample_frac(0.1, replace = FALSE)

  data_sample <- data %>%
    semi_join(gvkey_sample, by = "gvkey")

  df[ ,i] <- decompose_variance(y, X, fe)
}

col_c <- apply(df, 1, mean)
names(col_c) <- c(fe, X, "adjr2")

# Market Leverage: column (d) ------
X <- c("logsale", "mtb", "prof", "tang")
fe <- c("fyear", "ffind")

df <- matrix(nrow = length(X) + length(fe) + 1, ncol = 100)

for (i in 1:100){
  cat(i, "th Simulation\n")

  gvkey_sample <- data %>%
    distinct(gvkey) %>%
    sample_frac(0.1, replace = FALSE)

  data_sample <- data %>%
    semi_join(gvkey_sample, by = "gvkey")

  df[ ,i] <- decompose_variance(y, X, fe)
}

col_d <- apply(df, 1, mean)
names(col_d) <- c(fe, X, "adjr2")

# Market Leverage: column (e) ------
X <- c("logsale", "mtb", "prof", "tang")
fe <- c("gvkey", "fyear")

df <- matrix(nrow = length(X) + length(fe) + 1, ncol = 100)

for (i in 1:100){
  cat(i, "th Simulation\n")

  gvkey_sample <- data %>%
    distinct(gvkey) %>%
    sample_frac(0.1, replace = FALSE)

  data_sample <- data %>%
    semi_join(gvkey_sample, by = "gvkey")

  df[ ,i] <- decompose_variance(y, X, fe)
}

col_e <- apply(df, 1, mean)
names(col_e) <- c(fe, X, "adjr2")

# Market Leverage: column (f) ------
X <- c("logsale", "mtb", "prof", "tang", "indblev", "cfvol", "divpayer")
fe <- c("fyear", "ffind")

df <- matrix(nrow = length(X) + length(fe) + 1, ncol = 100)

for (i in 1:100){
  cat(i, "th Simulation\n")

  gvkey_sample <- data %>%
    distinct(gvkey) %>%
    sample_frac(0.1, replace = FALSE)

  data_sample <- data %>%
    semi_join(gvkey_sample, by = "gvkey")

  df[ ,i] <- decompose_variance(y, X, fe)
}

col_f <- apply(df, 1, mean)
names(col_f) <- c(fe, X, "adjr2")

# Market Leverage: column (g) ------
X <- c("logsale", "mtb", "prof", "tang", "indblev", "cfvol", "divpayer")
fe <- c("gvkey", "fyear")

df <- matrix(nrow = length(X) + length(fe) + 1, ncol = 100)

for (i in 1:100){
  cat(i, "th Simulation\n")

  gvkey_sample <- data %>%
    distinct(gvkey) %>%
    sample_frac(0.1, replace = FALSE)

  data_sample <- data %>%
    semi_join(gvkey_sample, by = "gvkey")

  df[ ,i] <- decompose_variance(y, X, fe)
}

col_g <- apply(df, 1, mean)
names(col_g) <- c(fe, X, "adjr2")

mlev_tab <- bind_rows(col_a, col_b, col_c, col_d, col_e, col_f, col_g) %>%
  select(gvkey, fyear, logsale, mtb, prof, tang, indblev, cfvol, divpayer, ffind, adjr2) %>%
  as.matrix() %>%
  t()

tab <- matrix(c(blev_tab, mlev_tab), 11, 14) %>%
  as_tibble() %>%
  mutate(varname = c("Firm FE", "Year FE", "Log(Sales)", "Market-to-book", "Profitability",
                     "Tangibility", "Industry med lev", "Cash flow vol", "Dividend payer", "Industry FE",
                     "Adj. Rsq")) %>%
  select(varname, everything())

haven::write_dta(tab, "analysis/temp/vardecompose.dta")
