library(dplyr)
library(data.table)
library(here)
library(ggplot2)
library(magrittr) # for %>% operator to be used with ggplot2

`%!in%` <- function(a, b){
    # makes code more readable by locating the ! next to the "in"
    return(!(a %in% b))
}

# read csv files into data.tables
app_record <- fread(here("/data/application_record.csv"), stringsAsFactors = TRUE)
credit_record <- fread(here("/data/credit_record.csv"), stringsAsFactors = TRUE)

# specify column types in app_record
app_record[,
           AGE := DAYS_BIRTH/-365,][,
           FLAG_WORK_PHONE := as.logical(FLAG_WORK_PHONE)][,
           FLAG_PHONE := as.logical(FLAG_PHONE)][,
           FLAG_EMAIL := as.logical(FLAG_EMAIL)][,
           FLAG_MOBIL := as.logical(FLAG_MOBIL)][,
           CNT_CHILDREN := as.integer(CNT_CHILDREN)][,
           CNT_FAM_MEMBERS := as.integer(CNT_FAM_MEMBERS)]

credit_record[, MONTHS_AGO := -MONTHS_BALANCE]
log_weighting <- 1 - log(credit_record$MONTHS_AGO + 1, 60)
norm_weighting <- 1 - credit_record$MONTHS_AGO / max(credit_record$MONTHS_AGO)

status_scores <- case_when(
    credit_record$STATUS == "5" ~ -6,
    credit_record$STATUS == "4" ~ -5,
    credit_record$STATUS == "3" ~ -4,
    credit_record$STATUS == "2" ~ -3,
    credit_record$STATUS == "1" ~ -2,
    credit_record$STATUS == "0" ~ -1,
    credit_record$STATUS == "X" ~ 0,
    credit_record$STATUS == "C" ~ 1,
)

credit_record[,
    STATUS_SCORE := status_scores][,
    LOG_WEIGHT := log_weighting][,
    NORM_WEIGHT := norm_weighting][,
    MIN_MAX_WEIGHT := (
        (MONTHS_AGO - min(MONTHS_AGO))/(max(MONTHS_AGO)-min(MONTHS_AGO))
    )][,
    LOG_SCORE := STATUS_SCORE * LOG_WEIGHT][,
    NORM_SCORE := STATUS_SCORE * NORM_WEIGHT][,
    MIN_MAX_SCORE := (
        (STATUS_SCORE - min(STATUS_SCORE))/(max(STATUS_SCORE)-min(STATUS_SCORE))
    )][,
    MIN_MAX_LOG := MIN_MAX_SCORE * LOG_WEIGHT][,
    MIN_MAX_NORM := MIN_MAX_SCORE * NORM_WEIGHT][,
    MIN_MAX_RELIABILITY := STATUS_SCORE * MIN_MAX_WEIGHT]

id_scores <- credit_record[, 
   .(
       NORM_SUM = sum(NORM_SCORE),
       LOG_SUM = sum(LOG_SCORE),
       NORM_MEAN = mean(NORM_SCORE),
       LOG_MEAN = mean(LOG_SCORE),
       MIN_MAX_LOG_SUM = sum(MIN_MAX_LOG),
       MIN_MAX_LOG_MEAN = mean(MIN_MAX_LOG),
       MIN_MAX_NORM_SUM = sum(MIN_MAX_NORM),
       MIN_MAX_NORM_MEAN = mean(MIN_MAX_NORM),
       MIN_MAX_SUM = sum(MIN_MAX_RELIABILITY),
       MIN_MAX_MEAN = sum(MIN_MAX_RELIABILITY)
    ), 
   by = ID
]

ggplot(id_scores, aes(x=MIN_MAX_MEAN)) + 
    geom_histogram(aes(y=..density..), color="blue", alpha=0.5, size=1) #+
    #geom_density(color="red", size=1)
ggsave(here("/pictures/log_sum.png"))

app_scores = data.table()
