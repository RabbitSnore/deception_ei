#######################################################################

# Wrangling

#######################################################################

# Load packages 

packages <- c("dplyr", "tidyr", "readxl")

lapply(packages, library, character.only = TRUE)

# Import data

raw <- read_xlsx("deception_ei_data.xlsx")

# Tidying up

## Change all column names to lower case

colnames(raw) <- tolower(colnames(raw))

## Select accuracy columns

accuracy <- raw %>% 
  select(ss, sex, starts_with("accur_"))

accuracy_long <- accuracy %>% 
  pivot_longer(
    cols = starts_with("accur_"),
    names_to = "name",
    values_to = "accuracy"
  ) %>% 
  extract(col = "name", into = c("sender", "veracity"), regex = "accur_(.*)_(.*)")

## Select EI and IRI measures

ei_data <- raw %>% 
  select(ss,
         ends_with("_st"),
         iri_pt, iri_ec, iri_fs, iri_pd)
  
## Join EI and IRI measures with accuracy

accuracy_long <- accuracy_long %>% 
  left_join(ei_data, by = "ss")

## Might as well grab confidence...
  
confidence <- raw %>% 
  select(ss, starts_with("confid_"))

confidence_long <- confidence %>% 
  pivot_longer(
    cols = starts_with("confid_"),
    names_to = "name",
    values_to = "confidence"
  ) %>% 
  extract(col = "name", into = c("sender", "veracity"), regex = "confid_(.*)_(.*)")
  

## Join confidence with the rest of its friends

accuracy_long <- accuracy_long %>% 
  left_join(confidence_long, by = c("ss", "sender", "veracity"))

## Reorder columns

accuracy_long <- accuracy_long %>% 
  select(ss, sender, veracity, accuracy, confidence, everything())

# Preparing detection criteria data

## Cognitive complexity

cog_complex <- raw %>% 
  select(ss, starts_with("cc_")) %>% 
  left_join(ei_data, by = "ss")

cog_long <- cog_complex %>% 
  pivot_longer(
    cols = starts_with("cc_"),
    names_to = "name",
    values_to = "criteria"
  ) %>% 
  extract(col = "name", into = c("sender", "veracity"), regex = "cc_(.*)_(.*)")

## Emotional features

emotion <- raw %>% 
  select(ss, sex, starts_with("ef_")) %>% 
  left_join(ei_data, by = "ss")

emotion_long <- emotion %>% 
  pivot_longer(
    cols = starts_with("ef_"),
    names_to = "name",
    values_to = "criteria"
  ) %>% 
  extract(col = "name", into = c("sender", "veracity"), regex = "ef_(.*)_(.*)")

## Expressive indices

expressive <- raw %>% 
  select(ss, starts_with("expi_")) %>% 
  left_join(ei_data, by = "ss")

expressive_long <- expressive %>% 
  pivot_longer(
    cols = starts_with("expi_"),
    names_to = "name",
    values_to = "criteria"
  ) %>% 
  extract(col = "name", into = c("sender", "veracity"), regex = "expi_(.*)_(.*)")

## Paraverbal aspects

paraverbal <- raw %>% 
  select(ss, starts_with("pa_")) %>% 
  left_join(ei_data, by = "ss")

paraverbal_long <- paraverbal %>% 
  pivot_longer(
    cols = starts_with("pa_"),
    names_to = "name",
    values_to = "criteria"
  ) %>% 
  extract(col = "name", into = c("sender", "veracity"), regex = "pa_(.*)_(.*)")

