
# Deception and Emotional Intelligence

This repository contains the code to wrangle and analyze the data from a study in the relationship between emotional intelligence and deception detection.

## Reproducing the analyses

Reproducing the analyses requires an installation of R (and preferably R Studio) and a copy of the data for the project. The most straightforward method for reproducing the analyses is to (1) clone this repository into an R Project; (2) add the data file to the repository and make sure it is named `deception_ei_data.xlsx` ; and (3) run all the code in `main_report.Rmd` or to knit it (I recommend HTML format). The report will call all the necessary scripts to wrangle the data and fit the statistical models.

The analyses require the following packages: `dplyr`, `tidyr`, `readxl`, `ggplot2`, `lme4`, and `lmerTest`. Knitting the report also requires `rmarkdown`.

These packages can be installed easily by running the following code.

```
install.packages(c("dplyr", "tidyr", "readxl", "ggplot2", "lme4", "lmerTest", "rmarkdown"))

```

