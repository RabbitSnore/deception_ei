#######################################################################

# Analysis

#######################################################################

# Load packages 

packages <- c("dplyr", "tidyr", "readxl", "ggplot2", "lme4")

lapply(packages, library, character.only = TRUE)

# HYPOTHESIS 1: Emotional intelligence, empathy, and accuracy

## Screening and assumption checking

### Correlations between predictors

h1_predictor_cor <- accuracy_long %>% 
  select(ends_with("_st"), starts_with("iri")) %>% 
  cor()

### Distributions of predictors

assumptions <- accuracy_long %>% 
  select(ends_with("_st"), starts_with("iri")) %>% 
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "value"
  )

#### Histograms

predictor_hist <- 
  ggplot(assumptions,
         aes(
           x = value
         )) +
  facet_wrap(~ variable,
             nrow = 4) +
  geom_histogram(
    bins = 20
  ) +
  theme_classic()

## Missing values

acc_na <- sum(is.na(accuracy_long$accuracy))
conf_na <- sum(is.na(accuracy_long$confidence))

## Set up variables

accuracy_long$veracity <- factor(accuracy_long$veracity, levels = c("truth", "liar"))

# Rescaling variables to troubleshoot identifiability issues

model_data <- accuracy_long %>% 
  mutate(
    iri_pt = iri_pt/10,
    iri_ec = iri_ec/10,
    iri_fs = iri_fs/10,
    iri_pd = iri_pd/10,
    r1g_st = r1g_st/10,
    r2g_st = r2g_st/10,
    r3g_st = r3g_st/10,
    r4g_st = r4g_st/10
  )

## Model specification and fitting

### Base model (random effects and veracity)

model_base <- glmer(accuracy ~ veracity + (1 + veracity|ss) + (1|sender), 
                    data = model_data, 
                    family = binomial(link = "logit")
                    )

### Add empathy

model_emp <- glmer(accuracy ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + (1 + veracity|ss) + (1|sender), 
                    data = model_data, 
                    family = binomial(link = "logit")
                    )

### Add emotional intelligence



### Compare models



### Preferred model



# HYPOTHESIS 2: Emotional intelligence, empathy, accuracy, and confidence