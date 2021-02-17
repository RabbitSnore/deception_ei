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
  select(ss, starts_with("accur_"))

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



