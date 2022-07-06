---
title: "Empathy, Emotional Intelligence, and Deception Detection -- Supplemental Report on Statistical Power"
author: "Timothy J. Luke"
date: "2022-07-06"
output: 
  html_document:
    keep_md: true
knit: (function(input_file, encoding) {
    rmarkdown::render(input_file, encoding = encoding, output_dir = "./reports/")
  })
---



Power analysis for mixed effects models poses many difficulties, but it is
possible to assess the power of the present study using a simulation-based
approach. Using the simr package (Green & MacLeod, 2016) for R 
(R Core Team, 2022), we extracted the fixed and random effects estimates from 
the fitted model, and we altered the fixed effects to test a range of effects. 
Given that any effects of individual difference measures on deception detection 
accuracy and calibration are likely to be quite small, we assessed power for 
effects equivalent to d = 0.10, 0.15, 0.20, and 0.25 (log odds ratio = 0.18, 
0.27, 0.36, and 0.45). Each of the four estimates was based on 1,000 
simulations. These simulations suggested that the present design provided 30.20%
power for d = 0.10, 54.00% for d = 0.15, 82.40% for d = 0.20, and 95.00% for d =
0.25. Thus, the present design provided a reasonable degree of statistical power
for relatively small effects (e.g., d = 0.20, 0.25), but we had inadequate power
to detect the smallest of effects. However, the effects for which the design was
inadequately powered may be so small as to be of minimal theoretical interest in 
any case. In sum, the present data have a reasonable amount of informational 
value.

Below are the results of the simulations. Effect sizes are provided in log odds
ratios.


```
## Power for predictor 'iri_pt', (95% confidence interval):
##       30.20% (27.37, 33.15)
## 
## Test: z-test
##       Effect size for iri_pt is 0.18
## 
## Based on 1000 simulations, (76 warnings, 0 errors)
## alpha = 0.05, nrow = 2100
## 
## Time elapsed: 2 h 38 m 41 s
```

```
## Power for predictor 'iri_pt', (95% confidence interval):
##       54.00% (50.85, 57.12)
## 
## Test: z-test
##       Effect size for iri_pt is 0.27
## 
## Based on 1000 simulations, (68 warnings, 0 errors)
## alpha = 0.05, nrow = 2100
## 
## Time elapsed: 2 h 41 m 1 s
```

```
## Power for predictor 'iri_pt', (95% confidence interval):
##       82.40% (79.90, 84.71)
## 
## Test: z-test
##       Effect size for iri_pt is 0.36
## 
## Based on 1000 simulations, (80 warnings, 0 errors)
## alpha = 0.05, nrow = 2100
## 
## Time elapsed: 2 h 38 m 28 s
```

```
## Power for predictor 'iri_pt', (95% confidence interval):
##       95.00% (93.46, 96.27)
## 
## Test: z-test
##       Effect size for iri_pt is 0.45
## 
## Based on 1000 simulations, (94 warnings, 0 errors)
## alpha = 0.05, nrow = 2100
## 
## Time elapsed: 2 h 5 m 35 s
```

For the code used to produce these simulations, see `power_simulation_010.R`, 
`power_simulation_015.R`, `power_simulation_020.R`, and 
`power_simulation_025.R^`. The code in each of these scripts is nearly identical
with the exception of the specification of the effect size. If you
want to reproduce these simulations, note that they are quite computationally
intensive. On the author's personal computer, the simulations took more than two
hours each. Some took nearly three hours.
