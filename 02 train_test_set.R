library(data.table)
library(here)
library(ggplot2)
library(magrittr) # for %>% operator to be used with ggplot2
library(readr)

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
    LOG_SCORE := STATUS_SCORE * LOG_WEIGHT][,
    NORM_SCORE := STATUS_SCORE * NORM_WEIGHT]

id_scores <- (
    credit_record[, 
        .(
            NORM = mean(NORM_SCORE),
            LOG = mean(LOG_SCORE)
        ), 
        by = ID
]
)

# split into groups
#first_time_apps <- app_record[ID %!in% credit_record$ID]
#histories_sans_app <- credit_record[ID %!in% app_record$ID]
#histories_with_app <- credit_record[ID %in% app_record$ID]
apps_with_history <- app_record[ID %in% credit_record$ID]
setkey(apps_with_history, ID)
setkey(id_scores,ID)

train_test_set <- merge(apps_with_history, id_scores, all.x = TRUE)
write_csv(train_test_set, here("/data/train_test_set.csv"))
