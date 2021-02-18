#######################################################################

# Signal detection theory analyses

#######################################################################

# Load packages 

packages <- c("dplyr", "tidyr", "readxl", "ggplot2", "psycho")

lapply(packages, library, character.only = TRUE)

# Hits, false alarms, misses, correct rejections

signal_long <- accuracy_long %>% 
  mutate(
    hit = case_when(
      veracity == "liar" & accuracy == 1   ~ 1,
      veracity == "liar" & accuracy == 0   ~ 0,
      veracity == "truth"                  ~ 0
    ),
    fa = case_when(
      veracity == "truth" & accuracy == 0  ~ 1,
      veracity == "truth" & accuracy == 1  ~ 0,
      veracity == "liar"                   ~ 0
    ),
    miss = case_when(
      veracity == "liar" & accuracy == 0   ~ 1,
      veracity == "liar" & accuracy == 1   ~ 0,
      veracity == "truth"                  ~ 0
    ),
    cr = case_when(
      veracity == "truth" & accuracy == 1  ~ 1,
      veracity == "truth" & accuracy == 0  ~ 0,
      veracity == "liar"                   ~ 0
    )
  )

## Hits

hit_wide <- signal_long %>% 
  pivot_wider(
    id_cols = "ss",
    names_from = "sender",
    values_from = "hit"
  ) %>% 
  select(-ss) %>% 
  mutate(
    hits = rowSums(., na.rm = TRUE)
  )

## False alarms

fa_wide <- signal_long %>% 
  pivot_wider(
    id_cols = "ss",
    names_from = "sender",
    values_from = "fa"
  ) %>% 
  select(-ss) %>% 
  mutate(
    fa = rowSums(., na.rm = TRUE)
  )

## Misses

miss_wide <- signal_long %>% 
  pivot_wider(
    id_cols = "ss",
    names_from = "sender",
    values_from = "miss"
  ) %>% 
  select(-ss) %>% 
  mutate(
    misses = rowSums(., na.rm = TRUE)
  )


## Correct rejections

cr_wide <- signal_long %>% 
  pivot_wider(
    id_cols = "ss",
    names_from = "sender",
    values_from = "cr"
  ) %>% 
  select(-ss) %>% 
  mutate(
    cr = rowSums(., na.rm = TRUE)
  )

## Signal detection indices

sdt_indices <- 
dprime(n_hit = hit_wide$hits, 
       n_fa = fa_wide$fa, 
       n_miss = miss_wide$misses, 
       n_cr = cr_wide$cr) %>% 
  as.data.frame()

## Binding data

sdt_data <- bind_cols(ei_data, sdt_indices)

# Modeling SDT indices

## d prime

### Empathy

model_sdt_emp <- lm(dprime ~ iri_pt + iri_ec + iri_fs + iri_pd, 
                   data = sdt_data)

### Add emotional intelligence

model_ei_sdt <- lm(dprime ~ iri_pt + iri_ec + iri_fs + iri_pd
                   + r1g_st + r2g_st + r3g_st + r4g_st, 
                   data = sdt_data)

### Model comparison

lrt_sdt_dprime <- anova(model_sdt_emp, model_ei_sdt)

## c (bias)

### Empathy

model_sdt_c_emp <- lm(c ~ iri_pt + iri_ec + iri_fs + iri_pd, 
                    data = sdt_data)

### Add emotional intelligence

model_ei_c_sdt <- lm(c ~ iri_pt + iri_ec + iri_fs + iri_pd
                   + r1g_st + r2g_st + r3g_st + r4g_st, 
                   data = sdt_data)

### Model comparison

lrt_sdt_bias <- anova(model_sdt_c_emp, model_ei_c_sdt)

