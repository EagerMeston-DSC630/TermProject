library(tidyverse)
library(here)
tt2 = read_csv(here("/data/train_test_set2.csv"))
predictors <- c("CODE_GENDER", "FLAG_OWN_CAR", "FLAG_OWN_REALTY", "CNT_CHILDREN",
                "AMT_INCOME_TOTAL", "NAME_INCOME_TYPE", "NAME_EDUCATION_TYPE",
                "NAME_FAMILY_STATUS", "NAME_HOUSING_TYPE", "DAYS_BIRTH", 
                "DAYS_EMPLOYED", "FLAG_MOBIL", "FLAG_WORK_PHONE", "FLAG_PHONE",
                "FLAG_EMAIL", "OCCUPATION_TYPE", "CNT_FAM_MEMBERS")
modf <- tt2[predictors]
modf$SCORE <- tt2$MIN_MAX_LOG_MEAN
summary(lm(SCORE ~ ., modf))
