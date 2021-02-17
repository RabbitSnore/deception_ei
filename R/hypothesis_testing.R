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

lrt_tests <- anova(model_base, model_emp, model_ei)

### Preferred model

#### Predicted accuracy

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

#### Confidence intervals

model_ci <- confint(model_ei, level = .95, parm = )
model_ci_or <- exp(model_ci) # Odds ratios


# HYPOTHESIS 2: Emotional intelligence, empathy, accuracy, and confidence


