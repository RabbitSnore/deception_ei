################################################################################

# Simulation-Based Power Analysis, d = .25

################################################################################

source("./R/wrangle.R")
source("./R/hypothesis_testing.R")

# Load packages ----------------------------------------------------------------

library(simr)

# Extract model information ----------------------------------------------------

fixed_org  <- model_ei@beta

random_org <- VarCorr(model_ei)

# Simulate ---------------------------------------------------------------------

## Specify fixed effect

fixed_test    <- fixed_org
fixed_test[3] <- .25 * (pi/sqrt(3))

## Build model

sim_glmer <- makeGlmer(
  formula = accuracy ~ veracity 
  + iri_pt + iri_ec + iri_fs + iri_pd 
  + r1g_st + r2g_st + r3g_st + r4g_st 
  + (1 + veracity|ss) + (1|sender), 
  family = binomial(link = "logit"),
  fixef = fixed_test,
  VarCorr = random_org,
  data = model_data
)

simulated_power <- powerSim(sim_glmer, test = fixed("iri_pt"), nsim = 1000)

save(simulated_power, file = "sim_outcome_025.rda")