
# Loading in necessary libraries

library(tidyverse)

# Loading in raw data

polls_past <- read_csv("data/08-prediction/raw-data/pollavg_1968-2016.csv")
polls_2020 <- read_csv("data/08-prediction/raw-data/president_polls.csv")
past_elections <- read_csv("data/08-prediction/raw-data/popvote_1948-2016.csv")
job_approval_gallup <- read_csv("data/08-prediction/raw-data/approval_gallup_1941-2020.csv")

# Cleaning for Past Polls:
# 1) Using only polls 22 weeks or closer to the election
# 2) Averaging for all candidates per year (by party)

polls_clean <- polls_past %>% 
  filter(weeks_left <= 22) %>% 
  group_by(year, party) %>% 
  summarize(average_poll = mean(avg_support), .groups = "drop")

# write_csv(polls_clean, "data/08-prediction/pollavg_1968-2016_clean.csv")

# Cleaning for 2020 Polls:
# 1) Removing state polls
# 2) Cleaning up dates
# 3) Using only polls 22 weeks or closer to the election (After June)
# 4) Averaging for all candidates (by party)
# 5) Selecting the democrat and republican parties and renaming them

polls_2020_clean <- polls_2020 %>% 
  filter(is.na(state)) %>% 
  mutate(start_date = as.Date(end_date, "%m/%d/%y")) %>% 
  filter(start_date >= "2020-06-01") %>% 
  group_by(candidate_party) %>% 
  summarize(average_poll = mean(pct), .groups = "drop") %>% 
  filter(candidate_party %in% c("DEM", "REP")) %>% 
  mutate(candidate_party = case_when(
    candidate_party == "DEM" ~ "democrat",
    candidate_party == "REP" ~ "republican"
  )) %>% 
  rename(party = candidate_party)

# write_csv(polls_2020_clean, "data/08-prediction/president_polls_clean.csv")

# Cleaning for past elections:
# 1) Add in previous year's pv2p for each party using lag. Removing 1948 data
# 2) Selecting year, party, winner, pv2p, last_pv2p, incumbent, incumbent_party

past_elections_clean <- past_elections %>% 
  group_by(party) %>% 
  mutate(last_pv2p = lag(pv2p, order_by = year)) %>% 
  ungroup() %>% 
  drop_na(last_pv2p) %>% 
  select(year, party, winner, pv2p, last_pv2p, incumbent, incumbent_party)

# write_csv(past_elections_clean, "data/08-prediction/popvote_1948-2016_clean.csv")  

# Cleaning job approval data:
# 1) Selecting data from Jan to Oct of election years
# 2) Averaging the approval ratings of each year

job_approval_gallup_clean <- job_approval_gallup %>% 
  mutate(year = as.numeric(format(as.Date(poll_startdate, format = "%Y-%m-%d"), "%Y")),
         month = as.numeric(format(as.Date(poll_startdate, format = "%Y-%m-%d"), "%m"))) %>% 
  filter(year %% 4 == 0,
         month %in% 1:10) %>% 
  group_by(year) %>% 
  summarize(job_approval = mean(approve), .groups = "drop")
  
# write_csv(job_approval_gallup_clean, "data/08-prediction/approval_gallup_1941-2020_clean.csv")
  
