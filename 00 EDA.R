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

# split into groups
first_time_apps <- app_record[ID %!in% credit_record$ID]
apps_with_history <- app_record[ID %in% credit_record$ID]
histories_sans_app <- credit_record[ID %!in% app_record$ID]
histories_with_app <- credit_record[ID %in% app_record$ID]

# investigate duplicate apps
duplicate_ids <- with(app_record, ID[duplicated(ID)])
duplicate_apps <- app_record[ID %in% duplicate_ids]
# verify that the apps were submitted at different times
duplicates <- duplicate_apps[,c("ID", "DAYS_BIRTH", "AGE")]
# They are usually submitted years apart, sometimes only months apart
(setorder(duplicates, ID))

# compare distribution of variables between first_time_apps and apps w/ history
# CODE_GENDER
with(first_time_apps, summary(CODE_GENDER) / length(CODE_GENDER))
with(apps_with_history, summary(CODE_GENDER) / length(CODE_GENDER))
# FLAG_OWN_CAR
with(first_time_apps, summary(FLAG_OWN_CAR) / length(FLAG_OWN_CAR))
with(apps_with_history, summary(FLAG_OWN_CAR) / length(FLAG_OWN_CAR))
# FLAG_OWN_REALTY
with(apps_with_history, summary(FLAG_OWN_REALTY) / length(FLAG_OWN_REALTY))
with(first_time_apps, summary(FLAG_OWN_REALTY) / length(FLAG_OWN_REALTY))
# CNT_CHILDREN
summary(first_time_apps$CNT_CHILDREN)
summary(apps_with_history$CNT_CHILDREN)
# AMT_INCOME_TOTAL
summary(first_time_apps$AMT_INCOME_TOTAL)
summary(apps_with_history$AMT_INCOME_TOTAL)
# NAME_INCOME_TYPE
with(first_time_apps, summary(NAME_INCOME_TYPE) / length(NAME_INCOME_TYPE))
with(apps_with_history, summary(NAME_INCOME_TYPE) / length(NAME_INCOME_TYPE))
# NAME_EDUCATION_TYPE
with(
    first_time_apps,
    summary(NAME_EDUCATION_TYPE) / length(NAME_EDUCATION_TYPE)
)
with(
    apps_with_history,
    summary(NAME_EDUCATION_TYPE) / length(NAME_EDUCATION_TYPE)
)
# NAME_FAMILY_STATUS
with(
    apps_with_history, summary(NAME_FAMILY_STATUS) / length(NAME_FAMILY_STATUS)
)
with(first_time_apps, summary(NAME_FAMILY_STATUS) / length(NAME_FAMILY_STATUS))
# NAME_HOUSING_TYPE
with(first_time_apps, summary(NAME_HOUSING_TYPE) / length(NAME_HOUSING_TYPE))
with(apps_with_history, summary(NAME_HOUSING_TYPE) / length(NAME_HOUSING_TYPE))
# DAYS_BIRTH
summary(apps_with_history$DAYS_BIRTH)
summary(first_time_apps$DAYS_BIRTH)
# DAYS_EMPLOYED
summary(first_time_apps$DAYS_EMPLOYED)
summary(apps_with_history$DAYS_EMPLOYED)
# FLAG_MOBIL
mean(apps_with_history$FLAG_MOBIL)
mean(first_time_apps$FLAG_MOBIL)
# FLAG_EMAIL
mean(first_time_apps$FLAG_EMAIL)
mean(apps_with_history$FLAG_EMAIL)
# FLAG_WORK_PHONE
mean(apps_with_history$FLAG_WORK_PHONE)
mean(first_time_apps$FLAG_WORK_PHONE)
# FLAG_PHONE
mean(first_time_apps$FLAG_PHONE)
mean(apps_with_history$FLAG_PHONE)
# OCCUPATION_TYPE
with(apps_with_history, summary(OCCUPATION_TYPE) / length(OCCUPATION_TYPE))
with(first_time_apps, summary(OCCUPATION_TYPE) / length(OCCUPATION_TYPE))
# CNT_FAM_MEMBERS
summary(first_time_apps$CNT_FAM_MEMBERS)
summary(apps_with_history$CNT_FAM_MEMBERS)
# AGE
summary(apps_with_history$AGE)
summary(first_time_apps$AGE)
