#######################################################################

# Analysis

#######################################################################

# Load packages 

packages <- c("dplyr", "tidyr", "readxl", "ggplot2", "lme4", "lmerTest")

lapply(packages, library, character.only = TRUE)

# HYPOTHESIS 1: Emotional intelligence, empathy, and accuracy -------------------

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

predictor_hist_ei <- assumptions %>% 
  filter(grepl(x = assumptions$variable, pattern = ".*_st")) %>% 
  ggplot(aes(
           x = value
         )) +
  facet_wrap(~ variable,
             nrow = 4) +
  geom_histogram(
    bins = 20
  ) +
  theme_classic()

predictor_hist_emp <- assumptions %>% 
  filter(grepl(x = assumptions$variable, pattern = "iri_.*")) %>% 
  ggplot(aes(
    x = value
  )) +
  facet_wrap(~ variable,
             nrow = 2) +
  geom_histogram(
    bins = 15
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
    iri_pt = scale(iri_pt/10, scale = FALSE),
    iri_ec = scale(iri_ec/10, scale = FALSE),
    iri_fs = scale(iri_fs/10, scale = FALSE),
    iri_pd = scale(iri_pd/10, scale = FALSE),
    r1g_st = scale(r1g_st/10, scale = FALSE),
    r2g_st = scale(r2g_st/10, scale = FALSE),
    r3g_st = scale(r3g_st/10, scale = FALSE),
    r4g_st = scale(r4g_st/10, scale = FALSE)
  )

## Model specification and fitting

### Base model (random effects and veracity)

model_base <- glmer(accuracy ~ veracity + (1 + veracity|ss) + (1|sender), 
                    data = model_data, 
                    family = binomial(link = "logit")
                    )

### Add empathy

model_emp <- glmer(accuracy ~ veracity 
                   + iri_pt + iri_ec + iri_fs + iri_pd 
                   + (1 + veracity|ss) + (1|sender), 
                   data = model_data, 
                   family = binomial(link = "logit")
                   )

### Add emotional intelligence

model_ei <- glmer(accuracy ~ veracity 
                   + iri_pt + iri_ec + iri_fs + iri_pd 
                   + r1g_st + r2g_st + r3g_st + r4g_st 
                   + (1 + veracity|ss) + (1|sender), 
                   data = model_data, 
                   family = binomial(link = "logit")
                   )

### Compare models

lrt_accuracy <- anova(model_base, model_emp, model_ei)

### Preferred model

#### Predicted accuracy from emotional intelligence

predict_data <- model_data

pred_seq <- seq(from = min(model_data$r1g_st), to = max(model_data$r1g_st), length.out = 100)

predict_probabilities <- lapply(pred_seq, function(x) {
  
  predict_data$r1g_st <- x
  
  predict(model_ei, newdata = predict_data, type = "response")

}

)

prob_mean  <- sapply(predict_probabilities, mean)
prob_upper <- sapply(predict_probabilities, quantile, probs = .95)
prob_lower <- sapply(predict_probabilities, quantile, probs = .05)

predict_plot_data <- data.frame(pred_seq, prob_mean, prob_upper, prob_lower)

predict_plot <- 
  ggplot(predict_plot_data,
         aes(
           x = pred_seq,
           y = prob_mean
         )) +
  geom_line(
    size = 1
  ) +
  coord_cartesian(
    ylim = c(0, 1)
  ) +
  geom_hline(
    yintercept = .50,
    linetype = "dashed"
  ) +
  geom_vline(
    xintercept = 0,
    linetype = "dotted"
  ) +
  scale_x_continuous(
    breaks = seq(-3, 3, 1) + round(mean(accuracy_long$r1g_st)) - mean(accuracy_long$r1g_st),
    labels = round((seq(-3, 3, 1) * 10) + mean(accuracy_long$r1g_st))
  ) +
  scale_y_continuous(
    breaks = seq(0, 1, .1)
  ) +
  labs(
    x = "Emotional Intelligence (Perceiving)",
    y = "Mean Predicted Accuracy"
  ) +
  theme_classic()

#### Predicted accuracy from perspective taking

predict_data_pt <- model_data

pred_seq_pt <- seq(from = min(model_data$iri_pt), to = max(model_data$iri_pt), length.out = 100)

predict_probabilities_pt <- lapply(pred_seq_pt, function(x) {
  
  predict_data_pt$iri_pt <- x
  
  predict(model_ei, newdata = predict_data_pt, type = "response")
  
}

)

prob_mean_pt  <- sapply(predict_probabilities_pt, mean)
prob_upper_pt <- sapply(predict_probabilities_pt, quantile, probs = .95)
prob_lower_pt <- sapply(predict_probabilities_pt, quantile, probs = .05)

predict_plot_data_pt <- data.frame(pred_seq_pt, prob_mean_pt, prob_upper_pt, prob_lower_pt)

predict_plot_pt <- 
  ggplot(predict_plot_data_pt,
         aes(
           x = pred_seq_pt,
           y = prob_mean_pt
         )) +
  geom_line(
    size = 1
  ) +
  coord_cartesian(
    ylim = c(0, 1)
  ) +
  geom_hline(
    yintercept = .50,
    linetype = "dashed"
  ) +
  geom_vline(
    xintercept = 0,
    linetype = "dotted"
  ) +
  scale_x_continuous(
    breaks = seq(-1.5, 1.5, .5) + round(mean(accuracy_long$iri_pt)) - mean(accuracy_long$iri_pt),
    labels = round((seq(-1.5, 1.5, .5) * 10) + mean(accuracy_long$iri_pt))
  ) +
  scale_y_continuous(
    breaks = seq(0, 1, .1)
  ) +
  labs(
    x = "Trait Empathy (Perspective Taking)",
    y = "Mean Predicted Accuracy"
  ) +
  theme_classic()


### Robustness checks

#### Removing empathy

model_ei_red <- glmer(accuracy ~ veracity  
                  + r1g_st + r2g_st + r3g_st + r4g_st 
                  + (1 + veracity|ss) + (1|sender), 
                  data = model_data, 
                  family = binomial(link = "logit")
                  )
# The effect for EI Perceiving persists when removing the empathy variables

#### Removing veracity

model_ei_ver <- glmer(accuracy ~ r1g_st + r2g_st + r3g_st + r4g_st 
                      + (1 + veracity|ss) + (1|sender), 
                      data = model_data, 
                      family = binomial(link = "logit")
                      )
# The effect for EI Perceiving persists when removing veracity

#### Using only the Perspective taking empathy subscale

model_emp_pt <- glmer(accuracy ~ veracity  
                      + iri_pt 
                      + (1 + veracity|ss) + (1|sender), 
                      data = model_data, 
                      family = binomial(link = "logit")
)
# The effect for Perspective taking persists with other variables removed


#### Using only EI perceiving

model_ei_per <- glmer(accuracy ~ veracity  
                      + r1g_st 
                      + (1 + veracity|ss) + (1|sender), 
                      data = model_data, 
                      family = binomial(link = "logit")
                      )
# The coefficient for EI Perceiving remains significant when removing other predictors

#### Using only EI using

model_ei_use <- glmer(accuracy ~ veracity  
                      + r2g_st 
                      + (1 + veracity|ss) + (1|sender), 
                      data = model_data, 
                      family = binomial(link = "logit")
                      )
# The negative coefficient for EI Using becomes nonsignificant when other predictors are removed

#### Using EI subscales

model_ei_sub <- glmer(accuracy ~ veracity + expg_st + strg_st
                      + (1 + veracity|ss) + (1|sender), 
                      data = model_data, 
                      family = binomial(link = "logit")
                      )
# No significant effects for the EI bifactor scores

#### Using EI total score

model_ei_tot <- glmer(accuracy ~ veracity + ttg_st
                      + (1 + veracity|ss) + (1|sender), 
                      data = model_data, 
                      family = binomial(link = "logit")
                      )
# No significant effect for the EI total score

# HYPOTHESIS 2: Emotional intelligence, empathy, accuracy, and confidence -------

## Does emotional intelligence make confidence (more) predictive of accuracy?

## Preparing data

model_data <- model_data %>% 
  mutate(
    confidence = scale(confidence, scale = FALSE)
  )

## Base model

model_conf_base <- glmer(accuracy ~ veracity + confidence + (1 + veracity|ss) + (1|sender), 
                    data = model_data, 
                    family = binomial(link = "logit")
                    )

## Add emotional intelligence

model_conf_ei <- glmer(accuracy ~ veracity + confidence
                       + r1g_st + iri_pt
                       + (1 + veracity|ss) + (1|sender),
                       data = model_data, 
                       family = binomial(link = "logit")
                       )

# The Perceiving subscale and the Perspective Taking subscale seem to be the best candidates for possibly interacting with confidence, so I will use it here instead of trying every EI and empathy facet.

## Add interaction

model_conf_ei_int <- glmer(accuracy ~ veracity 
                           + confidence*r1g_st + confidence*iri_pt
                           + (1 + veracity|ss) + (1|sender),
                           data = model_data, 
                           family = binomial(link = "logit")
                           )

## Model comparison

lrt_confidence <- anova(model_conf_base, model_conf_ei, model_conf_ei_int)

# This simply replicates the effect for Perceiving, but there is no evidence of an interaction with confidence

# HYPOTHESIS 3: Emotional intelligence and criteria for judgment ----------------

## Function for criteria model fitting

criteria_model <- function(data) {
  
  # Base
  
  model_1 <- lmer(criteria ~ veracity
                  + (1 + veracity|ss) + (1|sender), 
                  data = data)
  
  # Add empathy
  
  model_2 <- lmer(criteria ~ veracity 
                  + iri_pt + iri_ec + iri_fs + iri_pd 
                  + (1 + veracity|ss) + (1|sender), 
                  data = data)
  
  # Add emotional intelligence
  
  model_3 <- lmer(criteria ~ veracity 
                  + iri_pt + iri_ec + iri_fs + iri_pd 
                  + r1g_st + r2g_st + r3g_st + r4g_st 
                  + (1 + veracity|ss) + (1|sender), 
                  data = data)
  
  ## Model comparison
  
  lrt <- anova(model_1, model_2, model_3)
  
  model_list <- list(model_1, model_2, model_3, lrt)
  
  return(model_list)
    
}

cognitive_models  <- criteria_model(data = cog_long)
emotion_models    <- criteria_model(data = emotion_long)
expressive_models <- criteria_model(data = expressive_long)
paraverbal_models <- criteria_model(data = paraverbal_long)

# Cognitive models seem not to fit any better with empathy and EI added.
# Emotion model seems to benefit from the addition of empathy but not EI. The IRI Fantasy subscale seems to be significant.
# The expressive models do not seem to benefit from empathy or EI.
# Neither do the paraverbal models
