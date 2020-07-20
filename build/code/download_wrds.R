rm(list = ls())

library(RPostgres)
library(tidyverse)
library(labelled)

# set-up ------
wrds <- dbConnect(Postgres(),
                  host = 'wrds-pgdata.wharton.upenn.edu',
                  port = 9737,
                  dbname = 'wrds',
                  sslmode = 'require',
                  user = 'ysugk')

# look into table schema ------
# res <- dbSendQuery(wrds, "select distinct table_schema
#                    from information_schema.tables
#                    where table_type ='VIEW'
#                    or table_type ='FOREIGN TABLE'
#                    order by table_schema")
# data <- dbFetch(res, n = -1)
# dbClearResult(res)
# 
# res <- dbSendQuery(wrds, "select distinct table_name
#                    from information_schema.columns
#                    where table_schema='compa'
#                    order by table_name")
# data <- dbFetch(res, n = -1)
# dbClearResult(res)
# 
# res <- dbSendQuery(wrds, "select column_name
#                    from information_schema.columns
#                    where table_schema='compa'
#                    and table_name='funda'
#                    order by column_name")
# 
# data <- dbFetch(res, n = -1)
# dbClearResult(res)

# download funda ------
select_condition <- c(
  
  paste0("a.",
         c("gvkey", "datadate", "indfmt", "datafmt", "popsrc", "consol", "curcd", "costat", "sich",
           "fyear", "dlc", "dltt", "at", "oibdp", "txt", "xint", "dvp", 
           "dvc", "prcc_f", "cshpri", "pstkl", "txditc", "invt", "ppent", "pi", "sale", 
           "re", "act", "lct", "csho", "ajex", "opiti", "intan", "ebitda")),
  
  paste0("b.",
    c("sic"))
  
  ) %>%
  paste0(collapse = ", ")

where_condition <- c("(a.fyear between 1950 and 2010)", "AND",
                     "a.indfmt = 'INDL'", "AND",
                     "a.datafmt = 'STD'", "AND",
                     "a.popsrc = 'D'", "AND",
                     "a.consol = 'C'") %>%
  paste0(collapse = " ")

from_condition <- "comp.funda a"
join_condition <- "comp.company b ON a.gvkey = b.gvkey"

queue <- paste("SELECT", select_condition, "FROM", from_condition, "JOIN", join_condition, "WHERE", where_condition, sep = " ")

res <- dbSendQuery(wrds, queue)
data <- dbFetch(res, n = -1)
dbClearResult(res)

var_label(data) <- list(gvkey = "global key",
                        datadate = "data date",
                        indfmt = "industry format",
                        datafmt = "data format",
                        popsrc = "population source",
                        consol = "consolidation level",
                        curcd = "currency",
                        costat = "company status",
                        fyear = "fiscal year", 
                        sic = "sic code",
                        dlc = "short-term debt", 
                        dltt = "long-term debt", 
                        at = "total assets",
                        oibdp = "operating income before depreciation", 
                        txt = "income taxes - total",
                        txditc = "deferred taxes and investment tax credits",
                        xint = "interest and related expense - total",
                        dvp = "dividends - preferred",
                        dvc = "dividends - common",
                        prcc_f = "stock price", 
                        cshpri = "stock outstanding",
                        pstkl = "preferred stock liquidation value", 
                        invt = "inventory", 
                        ppent = "net PPE", 
                        pi = "pre-tax income", 
                        sale = "sales",
                        re = "retained earnings",
                        act = "current assets", 
                        lct = "current liabilities",
                        csho = "common shares outstanding",
                        ajex = "adjustment factor",
                        opiti = "operating income - total",
                        intan = "intangible assets",
                        ebitda = "EBITDA",
                        sich = "historical sic")

write_rds(data, "build/input/wrds/funda.rds", compress = "gz")

