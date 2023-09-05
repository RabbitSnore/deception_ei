---
title: "Empathy, Emotional Intelligence, and Deception Detection -- Main Report"
author: "Timothy J. Luke"
date: "2023-09-05"
output: 
  html_document:
    toc: true
    toc_float: true
    keep_md: true
knit: (function(input_file, encoding) {
    rmarkdown::render(input_file, encoding = encoding, output_dir = "./reports/")
  })
---



# Background

The main author of this report (Timothy) reviewed a manuscript for _Applied Cognitive Psychology_, which was ultimately rejected for publication. In that review, I recommended several potential ways of improving the statistical analyses and the interpretations thereof. I signed the review. Some time after the manuscript was rejected, the main author contacted me and asked if I would like to reanalyze the data and implement some of the things I recommended. I said yes.

This report contains my reanalysis of the data, as well as expansions of my initial reanalysis, in response to reviewer comments.

The report is constructed by calling a series of scripts containing the code to wrangle the data, fit the models, and draw the visualizations presented below.

# Initial examination of the data

## Distributions

First, we examined the distributions of the variables that would be used as predictors in the models testing the hypotheses.

Although the data distributions for the EI measure and trait empathy were certainly not normal, we don't see anything here that would make me very concerned about using it in a model.


```r
predictor_hist_ei
```

![](C:/Projects/deception_ei/reports/main_report_files/figure-html/unnamed-chunk-1-1.png)<!-- -->


```r
predictor_hist_emp
```

![](C:/Projects/deception_ei/reports/main_report_files/figure-html/unnamed-chunk-2-1.png)<!-- -->

## Correlations between predictors


```r
h1_predictor_cor
```

```
##              r1g_st      r2g_st      r3g_st      r4g_st     expg_st    strg_st
## r1g_st   1.00000000  0.37539011  0.16558576  0.20142236  0.82778687  0.2119804
## r2g_st   0.37539011  1.00000000  0.32416248  0.43803770  0.81943358  0.4292241
## r3g_st   0.16558576  0.32416248  1.00000000  0.37270927  0.31182970  0.8555035
## r4g_st   0.20142236  0.43803770  0.37270927  1.00000000  0.39643079  0.7775386
## expg_st  0.82778687  0.81943358  0.31182970  0.39643079  1.00000000  0.4046743
## strg_st  0.21198039  0.42922406  0.85550350  0.77753865  0.40467425  1.0000000
## ttg_st   0.69235919  0.78630354  0.61119489  0.62889398  0.90555702  0.7397398
## iri_pt   0.09954186  0.17130841  0.13601834  0.23125034  0.16764865  0.2261593
## iri_ec   0.01662886  0.03124789 -0.02238123  0.24150149  0.02306102  0.1443303
## iri_fs  -0.08426671 -0.04631128  0.12570933  0.09807013 -0.06906815  0.1691279
## iri_pd  -0.09110165 -0.19534909 -0.09468495 -0.20119916 -0.17782547 -0.1505796
##              ttg_st      iri_pt      iri_ec      iri_fs      iri_pd
## r1g_st   0.69235919  0.09954186  0.01662886 -0.08426671 -0.09110165
## r2g_st   0.78630354  0.17130841  0.03124789 -0.04631128 -0.19534909
## r3g_st   0.61119489  0.13601834 -0.02238123  0.12570933 -0.09468495
## r4g_st   0.62889398  0.23125034  0.24150149  0.09807013 -0.20119916
## expg_st  0.90555702  0.16764865  0.02306102 -0.06906815 -0.17782547
## strg_st  0.73973985  0.22615926  0.14433025  0.16912786 -0.15057960
## ttg_st   1.00000000  0.22416123  0.06994374  0.04201393 -0.20250085
## iri_pt   0.22416123  1.00000000  0.37903964  0.09429960 -0.10895131
## iri_ec   0.06994374  0.37903964  1.00000000  0.29162356  0.30526094
## iri_fs   0.04201393  0.09429960  0.29162356  1.00000000  0.16235875
## iri_pd  -0.20250085 -0.10895131  0.30526094  0.16235875  1.00000000
```

## Missing data

Thankfully, there is very little missing data. Just 1 missing accuracy value and 9 confidence values.


```r
acc_na # accuracy
```

```
## [1] 1
```

```r
conf_na # confidence
```

```
## [1] 9
```

# Hypothesis 1

To test the hypothesis that emotional intelligence and trait empathy predict higher deception detection accuracy, we fit a series of mixed effects logistic regression models. we then compared the models using likelihood ratio tests, to select a preferred model.

We wrangled the data into long form, such that each row represented a judgment by a receiver. Here are the first 20 rows, to illustrate the data structure.

Note that for the data used to test Hypothesis 1 and 2, I divided the emotional intelligence subscales and empathy subscales by 10 and mean centered them. These transformations were done to troubleshoot nearly unidentifiable models. The transformations should have no impact on the substantive interpretation of the models. To convert coefficients related to these variables back to the original scale, simply divide them by 10.


```r
head(model_data, 20) %>% 
  knitr::kable()
```



| ss|sender  |veracity | accuracy| confidence| sex| r1g_st|     r2g_st|     r3g_st|     r4g_st| expg_st| strg_st| ttg_st| iri_pt|      iri_ec|     iri_fs|      iri_pd|
|--:|:-------|:--------|--------:|----------:|---:|------:|----------:|----------:|----------:|-------:|-------:|------:|------:|-----------:|----------:|-----------:|
|  1|video1  |liar     |        1|  2.8235294|   0| -0.688| -2.4986667| -0.8353333| -0.6486667|      85|      97|     88|  0.298|  0.03666667| -1.1033333| -0.08733333|
|  1|video2  |liar     |        0|  1.8235294|   0| -0.688| -2.4986667| -0.8353333| -0.6486667|      85|      97|     88|  0.298|  0.03666667| -1.1033333| -0.08733333|
|  1|video3  |truth    |        1|  2.8235294|   0| -0.688| -2.4986667| -0.8353333| -0.6486667|      85|      97|     88|  0.298|  0.03666667| -1.1033333| -0.08733333|
|  1|video4  |truth    |        1|  0.8235294|   0| -0.688| -2.4986667| -0.8353333| -0.6486667|      85|      97|     88|  0.298|  0.03666667| -1.1033333| -0.08733333|
|  1|video5  |liar     |        1|  1.8235294|   0| -0.688| -2.4986667| -0.8353333| -0.6486667|      85|      97|     88|  0.298|  0.03666667| -1.1033333| -0.08733333|
|  1|video7  |truth    |        1|  2.8235294|   0| -0.688| -2.4986667| -0.8353333| -0.6486667|      85|      97|     88|  0.298|  0.03666667| -1.1033333| -0.08733333|
|  1|video8  |truth    |        1|  1.8235294|   0| -0.688| -2.4986667| -0.8353333| -0.6486667|      85|      97|     88|  0.298|  0.03666667| -1.1033333| -0.08733333|
|  1|video9  |liar     |        0|  1.8235294|   0| -0.688| -2.4986667| -0.8353333| -0.6486667|      85|      97|     88|  0.298|  0.03666667| -1.1033333| -0.08733333|
|  1|video10 |liar     |        0|  2.8235294|   0| -0.688| -2.4986667| -0.8353333| -0.6486667|      85|      97|     88|  0.298|  0.03666667| -1.1033333| -0.08733333|
|  1|video14 |liar     |        0|  1.8235294|   0| -0.688| -2.4986667| -0.8353333| -0.6486667|      85|      97|     88|  0.298|  0.03666667| -1.1033333| -0.08733333|
|  1|video15 |truth    |        1|  1.8235294|   0| -0.688| -2.4986667| -0.8353333| -0.6486667|      85|      97|     88|  0.298|  0.03666667| -1.1033333| -0.08733333|
|  1|video16 |truth    |        0|  2.8235294|   0| -0.688| -2.4986667| -0.8353333| -0.6486667|      85|      97|     88|  0.298|  0.03666667| -1.1033333| -0.08733333|
|  1|video18 |liar     |        1|  2.8235294|   0| -0.688| -2.4986667| -0.8353333| -0.6486667|      85|      97|     88|  0.298|  0.03666667| -1.1033333| -0.08733333|
|  1|video19 |truth    |        1| -3.1764706|   0| -0.688| -2.4986667| -0.8353333| -0.6486667|      85|      97|     88|  0.298|  0.03666667| -1.1033333| -0.08733333|
|  2|video1  |liar     |        0|  0.8235294|   0|  0.112| -0.9986667| -1.4353333| -1.6486667|      98|      89|     94| -0.002| -0.06333333| -0.6033333|  0.41266667|
|  2|video2  |liar     |        0|  0.8235294|   0|  0.112| -0.9986667| -1.4353333| -1.6486667|      98|      89|     94| -0.002| -0.06333333| -0.6033333|  0.41266667|
|  2|video3  |truth    |        0| -0.1764706|   0|  0.112| -0.9986667| -1.4353333| -1.6486667|      98|      89|     94| -0.002| -0.06333333| -0.6033333|  0.41266667|
|  2|video4  |truth    |        1| -0.1764706|   0|  0.112| -0.9986667| -1.4353333| -1.6486667|      98|      89|     94| -0.002| -0.06333333| -0.6033333|  0.41266667|
|  2|video5  |liar     |        1| -1.1764706|   0|  0.112| -0.9986667| -1.4353333| -1.6486667|      98|      89|     94| -0.002| -0.06333333| -0.6033333|  0.41266667|
|  2|video7  |truth    |        1|  1.8235294|   0|  0.112| -0.9986667| -1.4353333| -1.6486667|      98|      89|     94| -0.002| -0.06333333| -0.6033333|  0.41266667|

In the first model, deception detection accuracy (0 = incorrect, 1 = correct) was regressed on the veracity condition of the message (truth vs. lie), with random intercepts for senders, as well as random slopes (for veracity) and intercepts for receivers. In the second model, the four trait empathy subscales were added as predictors. In the third model, the four emotional intelligence subscales were added as predictors.

Likelihood ratio tests indicated at best marginal improvement by the addition of the empathy measures, but there was significant improvement of fit with the addition of the emotional intelligence measures.


```r
lrt_accuracy
```

```
## Data: model_data
## Models:
## model_base: accuracy ~ veracity + (1 + veracity | ss) + (1 | sender)
## model_emp: accuracy ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + (1 + veracity | ss) + (1 | sender)
## model_ei: accuracy ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + r1g_st + r2g_st + r3g_st + r4g_st + (1 + veracity | ss) + (1 | sender)
##            npar    AIC    BIC  logLik deviance   Chisq Df Pr(>Chisq)  
## model_base    6 2700.5 2734.4 -1344.2   2688.5                        
## model_emp    10 2700.5 2757.0 -1340.3   2680.5  7.9254  4    0.09435 .
## model_ei     14 2695.4 2774.5 -1333.7   2667.4 13.1150  4    0.01073 *
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

Thus, we retained the third model, which included both trait empathy and emotional intelligence. The main output of this model is provided below:


```r
summary(model_ei)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( logit )
## Formula: accuracy ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + r1g_st +  
##     r2g_st + r3g_st + r4g_st + (1 + veracity | ss) + (1 | sender)
##    Data: model_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2695.4   2774.5  -1333.7   2667.4     2085 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.3703 -0.8623 -0.4374  0.8883  2.5287 
## 
## Random effects:
##  Groups Name         Variance Std.Dev. Corr 
##  ss     (Intercept)  0.004196 0.06477       
##         veracityliar 0.056950 0.23864  -1.00
##  sender (Intercept)  0.523558 0.72357       
## Number of obs: 2099, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##              Estimate Std. Error z value Pr(>|z|)   
## (Intercept)   0.22941    0.28112   0.816  0.41447   
## veracityliar -0.57185    0.39871  -1.434  0.15150   
## iri_pt        0.27782    0.12398   2.241  0.02504 * 
## iri_ec       -0.12069    0.14921  -0.809  0.41859   
## iri_fs        0.06725    0.09760   0.689  0.49079   
## iri_pd        0.19330    0.12391   1.560  0.11876   
## r1g_st        0.10420    0.03443   3.027  0.00247 **
## r2g_st       -0.09772    0.04030  -2.425  0.01531 * 
## r3g_st        0.03599    0.03537   1.017  0.30892   
## r4g_st        0.03405    0.04260   0.799  0.42407   
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr) vrctyl iri_pt iri_ec iri_fs iri_pd r1g_st r2g_st r3g_st
## veracitylir -0.706                                                        
## iri_pt       0.002 -0.003                                                 
## iri_ec      -0.001  0.001 -0.399                                          
## iri_fs       0.000 -0.001  0.010 -0.229                                   
## iri_pd       0.002 -0.002  0.216 -0.389 -0.075                            
## r1g_st       0.002 -0.005 -0.023 -0.008  0.086  0.002                     
## r2g_st      -0.002  0.003 -0.070  0.031  0.064  0.071 -0.302              
## r3g_st       0.000 -0.001 -0.092  0.181 -0.156 -0.053 -0.043 -0.169       
## r4g_st       0.001  0.000 -0.008 -0.288 -0.033  0.230 -0.033 -0.302 -0.284
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

Interestingly but perhaps unsurprisingly, the variance in intercepts for senders massively exceeds the variance in intercepts for receivers. The sender variance exceeds the receiver variance by a factor of more than 124. As in Bond and DePaulo (2008), accuracy is primarily determined by the sender, rather than by the receiver.

Examining the coefficients, it appears that the Perceiving subscale of emotional intelligence appears to positively predict deception detection accuracy. The Perspective Taking subscale of the trait empathy instrument also appears to predict increased accuracy, but the p-value is fairly high (i.e., it would likely not survive a reasonable correction for multiple comparisons). The Using subscale of EI appears to negatively predict accuracy, but again, the p-value is relatively high, and we are not confident that this would survive corrections for multiple comparisons. Moreover, the significance of this coefficient is not robust to alternative models (see the supplemental analyses below).

To visualize the increase in accuracy apparently conferred by higher scores on the Perceiving EI subscale, we extracted the mean predicted accuracy rates from the preferred model at each level of the Perceiving subscale. The figure below illustrates the relationship between accuracy and the Perceiving subscale, with a horizontal line drawn at chance-level accuracy and a vertical line drawn at the sample mean on Perceiving.

The increase in accuracy might be theoretically interesting, if this effect is trustworthy, but it is not particularly impressive from a practical perspective. People with the highest score on Perceiving are predicted to have a mean accuracy of 55.7%. Interestingly, in this sample, participants scoring near the mean on Perceiving are predicted to have approximately chance-level accuracy.


```r
predict_plot
```

![](C:/Projects/deception_ei/reports/main_report_files/figure-html/unnamed-chunk-8-1.png)<!-- -->

Below is a similar plot illustrating how mean predicted accuracy varies as a function of the Perspective Taking subscale on the trait empathy measure. A participant with the highest Perspective Taking score in the sample is predicted to have a mean accuracy of 54.9%.


```r
predict_plot_pt
```

![](C:/Projects/deception_ei/reports/main_report_files/figure-html/unnamed-chunk-9-1.png)<!-- -->

## Exploration of Sender and Receiver Intercepts

The random intercept variance for senders was quite large, and the variance for receivers was quite small. Thus, it may be worthwhile to describe that variance in more detail.

To examine this variation, we fit a logistic regression model predicting accuracy only using random intercepts for senders and receivers.There were 14 sender videos used in this experiment, and their estimated average accuracy rates (derived by converting the random intercepts into the response scale) are as follows:


```r
sender_intercepts
```

```
##  [1] 0.4164914 0.2077334 0.2077334 0.4866508 0.5504557 0.7535296 0.4037477
##  [8] 0.3655556 0.5345926 0.7723578 0.6269138 0.6459900 0.4419933 0.4228653
```


```r
sender_int_range
```

```
## [1] 0.2077334 0.7723578
```

```r
sender_int_mean
```

```
## [1] 0.4883293
```

```r
sender_int_sd
```

```
## [1] 0.1737278
```

The intercepts for receivers are as follows:


```r
receiver_intercepts
```

```
##   [1] 0.4970791 0.4822814 0.5020140 0.4921447 0.4921447 0.4921447 0.5020140
##   [8] 0.4921447 0.4651221 0.4921447 0.4773542 0.4822814 0.4921447 0.4773542
##  [15] 0.4822814 0.4921447 0.4675135 0.4822814 0.4970791 0.4822814 0.4872119
##  [22] 0.4872119 0.4872119 0.4921447 0.4822814 0.4822814 0.4921447 0.4822814
##  [29] 0.4921447 0.4773542 0.4921447 0.4970791 0.4822814 0.4921447 0.4921447
##  [36] 0.4872119 0.4724313 0.5069485 0.5069485 0.4872119 0.4921447 0.4872119
##  [43] 0.4822814 0.4822814 0.4921447 0.4872119 0.4872119 0.4872119 0.5069485
##  [50] 0.4921447 0.4773542 0.4921447 0.5020140 0.4872119 0.4921447 0.4675135
##  [57] 0.4970791 0.4970791 0.4872119 0.4970791 0.4872119 0.4724313 0.4822814
##  [64] 0.4822814 0.4872119 0.4822814 0.5020140 0.4822814 0.4822814 0.5020140
##  [71] 0.4822814 0.4872119 0.4822814 0.4872119 0.4921447 0.4773542 0.4773542
##  [78] 0.4872119 0.4822814 0.4773542 0.5020140 0.4822814 0.4921447 0.4970791
##  [85] 0.4773542 0.4921447 0.4773542 0.4773542 0.4921447 0.4921447 0.4921447
##  [92] 0.4872119 0.5020140 0.4872119 0.4872119 0.4822814 0.4773542 0.4921447
##  [99] 0.4872119 0.5020140 0.4921447 0.4773542 0.4921447 0.4872119 0.4872119
## [106] 0.4921447 0.4872119 0.5020140 0.4872119 0.4773542 0.4970791 0.4921447
## [113] 0.4872119 0.4921447 0.4724313 0.4921447 0.4724313 0.4773542 0.4822814
## [120] 0.4773542 0.5020140 0.4921447 0.4872119 0.4724313 0.4724313 0.4773542
## [127] 0.4872119 0.4822814 0.4626017 0.4773542 0.4773542 0.4724313 0.4822814
## [134] 0.4773542 0.4921447 0.4921447 0.4773542 0.4921447 0.4921447 0.4773542
## [141] 0.4921447 0.4822814 0.4822814 0.4626017 0.4773542 0.4773542 0.4872119
## [148] 0.4773542 0.4822814 0.4822814
```

```r
receiver_int_range
```

```
## [1] 0.4626017 0.5069485
```

```r
receiver_int_mean 
```

```
## [1] 0.486411
```

```r
receiver_int_sd   
```

```
## [1] 0.008959288
```

It is easy to see there is a great deal more variability in senders than in receivers.

## Do the Effects of Perceiving and Perspective Taking Vary Across Senders?

It is reasonable to ask whether the Perceiving subscale and the Perspective Taking subscale had differential effects across senders, given that there is so much variability in senders. Such differences can be modeled as random slopes for Perceiving and Perspective Taking for senders. These random slopes represent variation in the extent to which Perceiving and Perspective Taking render some senders more transparent. These slopes should vary considerably if, for example, senders varied substantively in the extent to which there were "hidden" emotional information in their messages, such that the detection of such emotional information (facilitated by Perceiving or Perspective Taking) would assist a receiver in accurately judging the message.


```r
sender_slope_lrt
```

```
## Data: model_data
## Models:
## model_ei: accuracy ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + r1g_st + r2g_st + r3g_st + r4g_st + (1 + veracity | ss) + (1 | sender)
## model_ei_sender_slopes: accuracy ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + r1g_st + r2g_st + r3g_st + r4g_st + (1 + veracity | ss) + (1 + iri_pt + r1g_st | sender)
##                        npar    AIC    BIC  logLik deviance  Chisq Df Pr(>Chisq)
## model_ei                 14 2695.4 2774.5 -1333.7   2667.4                     
## model_ei_sender_slopes   19 2705.1 2812.4 -1333.5   2667.1 0.3355  5     0.9969
```


```r
summary(model_ei_sender_slopes)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( logit )
## Formula: accuracy ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + r1g_st +  
##     r2g_st + r3g_st + r4g_st + (1 + veracity | ss) + (1 + iri_pt +  
##     r1g_st | sender)
##    Data: model_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2705.1   2812.4  -1333.5   2667.1     2080 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.3903 -0.8622 -0.4377  0.8890  2.5155 
## 
## Random effects:
##  Groups Name         Variance  Std.Dev. Corr       
##  ss     (Intercept)  4.145e-03 0.064379            
##         veracityliar 5.662e-02 0.237939 -1.00      
##  sender (Intercept)  5.247e-01 0.724375            
##         iri_pt       4.327e-03 0.065777  1.00      
##         r1g_st       9.093e-05 0.009536 -1.00 -1.00
## Number of obs: 2099, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##              Estimate Std. Error z value Pr(>|z|)   
## (Intercept)   0.24722    0.28893   0.856  0.39218   
## veracityliar -0.60629    0.42140  -1.439  0.15022   
## iri_pt        0.27746    0.12519   2.216  0.02667 * 
## iri_ec       -0.12071    0.14915  -0.809  0.41836   
## iri_fs        0.06736    0.09765   0.690  0.49029   
## iri_pd        0.19385    0.12390   1.565  0.11769   
## r1g_st        0.10421    0.03451   3.019  0.00253 **
## r2g_st       -0.09774    0.04029  -2.426  0.01526 * 
## r3g_st        0.03572    0.03535   1.010  0.31233   
## r4g_st        0.03437    0.04259   0.807  0.41975   
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr) vrctyl iri_pt iri_ec iri_fs iri_pd r1g_st r2g_st r3g_st
## veracitylir -0.724                                                        
## iri_pt       0.105 -0.014                                                 
## iri_ec       0.001 -0.001 -0.394                                          
## iri_fs       0.001 -0.001  0.009 -0.229                                   
## iri_pd      -0.001  0.003  0.214 -0.389 -0.075                            
## r1g_st      -0.048 -0.005 -0.033 -0.009  0.086  0.003                     
## r2g_st      -0.002  0.003 -0.069  0.032  0.063  0.069 -0.302              
## r3g_st       0.001 -0.003 -0.092  0.181 -0.156 -0.053 -0.043 -0.169       
## r4g_st       0.002 -0.001 -0.008 -0.288 -0.032  0.230 -0.031 -0.303 -0.284
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

We see here there is virtually no variation in these random slopes. This lack of variation does not help clarify the mechanism by which Perceiving and Perspective Taking increase judgment accuracy. In fact, it raises more questions than it answers.

## Signal Detection Theory approach

From the above analyses, we cannot safely assume that the increases in accuracy associated with EI and empathy are not due to changes in bias, rather than changes in discrimination. For that reason, we calculated signal detection indices for each receiver. Specifically, we examined d-prime (a measure of discrimination) and c (a measure of bias). For each index, we fit a series of linear regressions predicting the index, first adding the empathy subscales as predictors and then adding the EI subscales as predictors. we compared the models using an F-test, to select a preferred model.


```r
sdt_data %>% 
  summarise(
    mean_dprime   = mean(dprime),
    sd_dprime     = sd(dprime),
    median_dprime = median(dprime),
    mean_c        = mean(c),
    sd_c          = sd(c),
    median_c      = median(c)
  )
```

```
## # A tibble: 1 × 6
##   mean_dprime sd_dprime median_dprime mean_c  sd_c median_c
##         <dbl>     <dbl>         <dbl>  <dbl> <dbl>    <dbl>
## 1     -0.0524     0.641             0  0.154 0.322    0.157
```

For d-prime, the model comparison suggested that the model adding the EI subscales significantly improved the fit.


```r
lrt_sdt_dprime
```

```
## Analysis of Variance Table
## 
## Model 1: dprime ~ iri_pt + iri_ec + iri_fs + iri_pd
## Model 2: dprime ~ iri_pt + iri_ec + iri_fs + iri_pd + r1g_st + r2g_st + 
##     r3g_st + r4g_st
##   Res.Df    RSS Df Sum of Sq      F   Pr(>F)   
## 1    145 57.931                                
## 2    141 52.601  4      5.33 3.5718 0.008301 **
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

This model effectively replicates the results from the logistic regression of the raw accuracy reported above. We see the same pattern of significant coefficients, in the same directions.

These results address some of the concerns raised in Timothy's review -- specifically that the results might be due to a change in bias rather than a change in discrimination.


```r
summary(model_ei_sdt)
```

```
## 
## Call:
## lm(formula = dprime ~ iri_pt + iri_ec + iri_fs + iri_pd + r1g_st + 
##     r2g_st + r3g_st + r4g_st, data = sdt_data)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -1.74512 -0.38586 -0.04534  0.36448  1.71574 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)   
## (Intercept) -1.960129   0.675987  -2.900  0.00433 **
## iri_pt       0.029582   0.013134   2.252  0.02585 * 
## iri_ec      -0.014890   0.015841  -0.940  0.34883   
## iri_fs       0.006861   0.010376   0.661  0.50953   
## iri_pd       0.022542   0.013129   1.717  0.08818 . 
## r1g_st       0.011120   0.003633   3.061  0.00264 **
## r2g_st      -0.011002   0.004266  -2.579  0.01094 * 
## r3g_st       0.004432   0.003746   1.183  0.23879   
## r4g_st       0.004165   0.004497   0.926  0.35596   
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.6108 on 141 degrees of freedom
## Multiple R-squared:  0.1396,	Adjusted R-squared:  0.09078 
## F-statistic:  2.86 on 8 and 141 DF,  p-value: 0.005621
```

Indeed, if we examine the models predicting bias (measured by c), we see that adding the EI measures does not improve the fit of the model, and the model that includes the empathy measures suggests no significant differences in bias. Moreover, the adjusted R-squared is negative, suggesting very poor fit with the data.


```r
lrt_sdt_bias
```

```
## Analysis of Variance Table
## 
## Model 1: c ~ iri_pt + iri_ec + iri_fs + iri_pd
## Model 2: c ~ iri_pt + iri_ec + iri_fs + iri_pd + r1g_st + r2g_st + r3g_st + 
##     r4g_st
##   Res.Df    RSS Df Sum of Sq      F Pr(>F)
## 1    145 15.436                           
## 2    141 14.805  4   0.63113 1.5027 0.2046
```


```r
summary(model_sdt_c_emp)
```

```
## 
## Call:
## lm(formula = c ~ iri_pt + iri_ec + iri_fs + iri_pd, data = sdt_data)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -1.35902 -0.16266 -0.00715  0.18170  1.39265 
## 
## Coefficients:
##               Estimate Std. Error t value Pr(>|t|)
## (Intercept)  0.1732334  0.2378898   0.728    0.468
## iri_pt      -0.0008838  0.0069195  -0.128    0.899
## iri_ec       0.0037613  0.0080578   0.467    0.641
## iri_fs      -0.0008357  0.0054348  -0.154    0.878
## iri_pd      -0.0041092  0.0067211  -0.611    0.542
## 
## Residual standard error: 0.3263 on 145 degrees of freedom
## Multiple R-squared:  0.003306,	Adjusted R-squared:  -0.02419 
## F-statistic: 0.1203 on 4 and 145 DF,  p-value: 0.9751
```

In short, the signal detection approach supports the results from the raw accuracy models.

### GLMM approach to SDT

It is also possible to fit generalized linear (mixed) models to perform signal detection analysis (see DeCarlo, 1998, https://doi.org/10.1037/1082-989X.3.2.186). There are many ways to implement this approach. Here, we fit a series of probit models predicting participants' responses using the message's actual veracity. The intercept represents -1*c (bias), and the coefficient for actual veracity represents d-prime. Coefficients for the predictors represent the influence of those predictors on response bias (c). Interaction terms between veracity and the predictors of interest represent the effect of those predictors on d-prime. Following an approach analogous to the main analysis above, we fit a series of models and compared them with likelihood ratio tests.


```r
lrt_sdtglm
```

```
## Data: sdtglm_data
## Models:
## sdtglm_base: response ~ veracity_01 + (1 + veracity_01 | ss) + (1 | sender)
## sdtglm_emp: response ~ veracity_01 + iri_pt * veracity_01 + iri_ec * veracity_01 + iri_fs * veracity_01 + iri_pd * veracity_01 + (1 + veracity_01 | ss) + (1 | sender)
## sdtglm_ei: response ~ veracity_01 + iri_pt * veracity_01 + iri_ec * veracity_01 + iri_fs * veracity_01 + iri_pd * veracity_01 + r1g_st * veracity_01 + r2g_st * veracity_01 + r3g_st * veracity_01 + r4g_st * veracity_01 + (1 + veracity_01 | ss) + (1 | sender)
##             npar    AIC    BIC  logLik deviance   Chisq Df Pr(>Chisq)  
## sdtglm_base    6 2700.6 2734.5 -1344.3   2688.6                        
## sdtglm_emp    14 2708.0 2787.1 -1340.0   2680.0  8.6164  8    0.37568  
## sdtglm_ei     22 2706.4 2830.7 -1331.2   2662.4 17.5470  8    0.02489 *
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```


```r
summary(sdtglm_ei)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( probit )
## Formula: 
## response ~ veracity_01 + iri_pt * veracity_01 + iri_ec * veracity_01 +  
##     iri_fs * veracity_01 + iri_pd * veracity_01 + r1g_st * veracity_01 +  
##     r2g_st * veracity_01 + r3g_st * veracity_01 + r4g_st * veracity_01 +  
##     (1 + veracity_01 | ss) + (1 | sender)
##    Data: sdtglm_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2706.4   2830.7  -1331.2   2662.4     2077 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.1245 -0.8314 -0.4918  0.9428  2.4998 
## 
## Random effects:
##  Groups Name        Variance Std.Dev. Corr
##  ss     (Intercept) 0.000316 0.01778      
##         veracity_01 0.002425 0.04924  1.00
##  sender (Intercept) 0.194838 0.44140      
## Number of obs: 2099, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##                    Estimate Std. Error z value Pr(>|z|)   
## (Intercept)        -0.14071    0.17154  -0.820  0.41208   
## veracity_01        -0.06621    0.24290  -0.273  0.78516   
## iri_pt             -0.14723    0.10492  -1.403  0.16053   
## iri_ec             -0.01377    0.12647  -0.109  0.91332   
## iri_fs             -0.03358    0.08276  -0.406  0.68488   
## iri_pd             -0.04835    0.10506  -0.460  0.64539   
## r1g_st             -0.08961    0.02917  -3.072  0.00213 **
## r2g_st              0.04830    0.03387   1.426  0.15388   
## r3g_st             -0.03105    0.02995  -1.037  0.29993   
## r4g_st              0.02168    0.03589   0.604  0.54577   
## veracity_01:iri_pt  0.33951    0.15170   2.238  0.02522 * 
## veracity_01:iri_ec -0.15289    0.18298  -0.836  0.40340   
## veracity_01:iri_fs  0.08224    0.11945   0.688  0.49116   
## veracity_01:iri_pd  0.24483    0.15165   1.615  0.10642   
## veracity_01:r1g_st  0.12452    0.04213   2.956  0.00312 **
## veracity_01:r2g_st -0.11881    0.04908  -2.421  0.01549 * 
## veracity_01:r3g_st  0.03854    0.04316   0.893  0.37195   
## veracity_01:r4g_st  0.04765    0.05174   0.921  0.35707   
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

```
## 
## Correlation matrix not shown by default, as p = 18 > 12.
## Use print(x, correlation=TRUE)  or
##     vcov(x)        if you need it
```

```
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

As can be seen, the results of this approach are highly similar to the logistic regression approach predicting accuracy and highly similar to the classical SDT approach. Again, we see that the clearest predictor of discrimination is the Perceiving subscale of the MSCEIT. 

However, unlike in previous analyses, we can see here that the Perceiving subscale of the MSCEIT also predicts response bias, such that those higher on Perceiving are more truth biased. This result does not appear in the classical SDT approach above.

# Hypothesis 2

Next, we turned our attention to the question of whether emotional intelligence and trait empathy give receivers better accuracy-confidence calibration. This calibration can be represented as a coefficient for confidence predicting accuracy (at the judgment level), and an increase in calibration would be represented by an interaction term for confidence and either EI or empathy.

To investigate this question, we fit a series of mixed effects logistic regression models, similar to the ones above. In the initial model, confidence and veracity predicted accuracy. As can be seen below, in this initial model, there is no relationship between accuracy and confidence. The coefficient is very close to 0.


```r
summary(model_conf_base)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( logit )
## Formula: accuracy ~ veracity + confidence + (1 + veracity | ss) + (1 |  
##     sender)
##    Data: model_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2692.1   2731.6  -1339.0   2678.1     2084 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -1.8803 -0.8493 -0.4869  0.9092  2.0303 
## 
## Random effects:
##  Groups Name         Variance Std.Dev. Corr
##  ss     (Intercept)  0.002532 0.05032      
##         veracityliar 0.036485 0.19101  0.83
##  sender (Intercept)  0.516055 0.71837      
## Number of obs: 2091, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##                Estimate Std. Error z value Pr(>|z|)
## (Intercept)   0.2269722  0.2791398   0.813    0.416
## veracityliar -0.5688481  0.3958213  -1.437    0.151
## confidence    0.0005533  0.0251294   0.022    0.982
## 
## Correlation of Fixed Effects:
##             (Intr) vrctyl
## veracitylir -0.705       
## confidence   0.008 -0.009
```

Based on the models testing Hypothesis 1, we regarded the Perceiving EI subscale and the Perspective Taking empathy subscale as the best candidates to interact with confidence. Thus, we fit models in which (1) those scales were added and (2) their interaction terms with confidence were added. I then compared these models to the base model using a likelihood ratio test, to select a model. The model comparison suggested a significant improvement of fit adding EI and empathy, but there was no improvement of fit with the addition of the interaction terms.


```r
lrt_confidence
```

```
## Data: model_data
## Models:
## model_conf_base: accuracy ~ veracity + confidence + (1 + veracity | ss) + (1 | sender)
## model_conf_ei: accuracy ~ veracity + confidence + r1g_st + iri_pt + (1 + veracity | ss) + (1 | sender)
## model_conf_ei_int: accuracy ~ veracity + confidence * r1g_st + confidence * iri_pt + (1 + veracity | ss) + (1 | sender)
##                   npar    AIC    BIC  logLik deviance   Chisq Df Pr(>Chisq)   
## model_conf_base      7 2692.1 2731.6 -1339.0   2678.1                         
## model_conf_ei        9 2685.2 2736.0 -1333.6   2667.2 10.8628  2   0.004377 **
## model_conf_ei_int   11 2689.0 2751.1 -1333.5   2667.0  0.2235  2   0.894253   
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

Since the interaction terms did not improve the model fit, there does not appear to be any evidence that emotional intelligence and empathy improve confidence-accuracy calibration. In the selected model (output below), the Perceiving EI subscale significantly predicts accuracy as above, but the coefficient for Perspective Taking is no longer significant. These results reduce our confidence that Perspective Taking really predicts accuracy.


```r
summary(model_conf_ei)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( logit )
## Formula: accuracy ~ veracity + confidence + r1g_st + iri_pt + (1 + veracity |  
##     ss) + (1 | sender)
##    Data: model_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2685.2   2736.0  -1333.6   2667.2     2082 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.1792 -0.8662 -0.4500  0.8961  2.3586 
## 
## Random effects:
##  Groups Name         Variance Std.Dev. Corr 
##  ss     (Intercept)  0.001129 0.0336        
##         veracityliar 0.067044 0.2589   -1.00
##  sender (Intercept)  0.520881 0.7217        
## Number of obs: 2091, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##               Estimate Std. Error z value Pr(>|z|)  
## (Intercept)   0.227780   0.280363   0.812   0.4165  
## veracityliar -0.571209   0.397832  -1.436   0.1511  
## confidence   -0.002328   0.025135  -0.093   0.9262  
## r1g_st        0.080487   0.032174   2.502   0.0124 *
## iri_pt        0.210297   0.110836   1.897   0.0578 .
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr) vrctyl cnfdnc r1g_st
## veracitylir -0.705                     
## confidence   0.008 -0.010              
## r1g_st       0.001 -0.005 -0.021       
## iri_pt       0.001 -0.002 -0.043 -0.093
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

## Signal Detection Approach (GLMM)

It is also possible to assess the confidence-accuracy relationship in an SDT framework, following the same approach as with the above SDT analyses. Here, we fit three models analogous to the confidence-accuracy models above.


```r
lrt_sdtglm_conf
```

```
## Data: sdtglm_data
## Models:
## sdtglm_conf_base: response ~ veracity_01 + confidence * veracity_01 + (1 + veracity_01 | ss) + (1 | sender)
## sdtglm_conf_emp: response ~ veracity_01 + confidence * veracity_01 + r1g_st * veracity_01 + iri_pt * veracity_01 + (1 + veracity_01 | ss) + (1 | sender)
## sdtglm_conf_int: response ~ veracity_01 + confidence * veracity_01 + r1g_st * confidence * veracity_01 + iri_pt * confidence * veracity_01 + (1 + veracity_01 | ss) + (1 | sender)
##                  npar    AIC    BIC  logLik deviance   Chisq Df Pr(>Chisq)  
## sdtglm_conf_base    8 2692.8 2737.9 -1338.4   2676.8                        
## sdtglm_conf_emp    12 2688.5 2756.2 -1332.2   2664.5 12.2752  4    0.01542 *
## sdtglm_conf_int    16 2694.2 2784.6 -1331.1   2662.2  2.2487  4    0.69013  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```


```r
summary(sdtglm_conf_emp)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( probit )
## Formula: response ~ veracity_01 + confidence * veracity_01 + r1g_st *  
##     veracity_01 + iri_pt * veracity_01 + (1 + veracity_01 | ss) +  
##     (1 | sender)
##    Data: sdtglm_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2688.5   2756.2  -1332.3   2664.5     2079 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -1.9487 -0.8333 -0.4964  0.9503  2.2583 
## 
## Random effects:
##  Groups Name        Variance Std.Dev. Corr
##  ss     (Intercept) 0.00000  0.0000       
##         veracity_01 0.01847  0.1359    NaN
##  sender (Intercept) 0.19197  0.4381       
## Number of obs: 2091, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##                         Estimate Std. Error z value Pr(>|z|)   
## (Intercept)            -0.142038   0.170352  -0.834  0.40440   
## veracity_01            -0.066513   0.241467  -0.275  0.78297   
## confidence             -0.014668   0.020835  -0.704  0.48142   
## r1g_st                 -0.071385   0.026952  -2.649  0.00808 **
## iri_pt                 -0.123788   0.092933  -1.332  0.18285   
## veracity_01:confidence -0.005405   0.030910  -0.175  0.86119   
## veracity_01:r1g_st      0.094037   0.039766   2.365  0.01804 * 
## veracity_01:iri_pt      0.258175   0.136958   1.885  0.05942 . 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr) vrc_01 cnfdnc r1g_st iri_pt vr_01: v_01:1
## veracity_01 -0.705                                          
## confidence   0.016 -0.011                                   
## r1g_st       0.002 -0.001 -0.023                            
## iri_pt       0.001  0.000 -0.044 -0.104                     
## vrcty_01:cn -0.011  0.008 -0.674  0.016  0.029              
## vrcty_01:1_ -0.001 -0.001  0.016 -0.678  0.071 -0.012       
## vrcty_01:r_  0.000  0.000  0.030  0.071 -0.679 -0.044 -0.101
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

Once again, we see that the SDT approach yields basically the same results as the raw accuracy approach. Confidence does not appear to predict truth-lie discrimination (as measured by d-prime). Indeed, the estimated relationship (i.e., the interaction term between confidence and veracity) is very close to zero.

# Hypothesis 3

The third research question concerned whether emotional intelligence and trait empathy predicted the judgment criteria provided by the receivers. Receivers' listed criteria were coded into four categories: cognitive complexity, emotional features, expressive indices, and paraverbal aspects.

For each of these categories, we fit and compared a series of linear mixed effects models. In the first model, the number of criteria listed was predicted by veracity, with random intercepts and slopes for each receiver and random intercepts for each sender. In the second model, the four empathy subscales were added as predictors. In the third model, the four emotional intelligence subscales were added as predictors. We compared each of these models using likelihood ratio tests to find a preferred model.

## Cognitive Complexity

The model selection procedure suggested that neither empathy nor EI predicted receivers reporting cognitive complexity criteria.


```r
cognitive_models[[4]]
```

```
## Data: data
## Models:
## model_1: criteria ~ veracity + (1 + veracity | ss) + (1 | sender)
## model_2: criteria ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + (1 + veracity | ss) + (1 | sender)
## model_3: criteria ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + r1g_st + r2g_st + r3g_st + r4g_st + (1 + veracity | ss) + (1 | sender)
##         npar    AIC    BIC  logLik deviance  Chisq Df Pr(>Chisq)
## model_1    7 4498.3 4537.8 -2242.1   4484.3                     
## model_2   11 4501.7 4563.8 -2239.8   4479.7 4.6120  4     0.3295
## model_3   15 4507.0 4591.7 -2238.5   4477.0 2.6925  4     0.6105
```


```r
summary(cognitive_models[[1]])
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: criteria ~ veracity + (1 + veracity | ss) + (1 | sender)
##    Data: data
## 
## REML criterion at convergence: 4493.2
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.3806 -0.7631  0.0087  0.5488  3.8106 
## 
## Random effects:
##  Groups   Name         Variance Std.Dev. Corr 
##  ss       (Intercept)  0.111274 0.33358       
##           veracityliar 0.010906 0.10443  -0.13
##  sender   (Intercept)  0.006183 0.07863       
##  Residual              0.440581 0.66376       
## Number of obs: 2098, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##              Estimate Std. Error       df t value Pr(>|t|)    
## (Intercept)   0.79469    0.04523 27.77562  17.571   <2e-16 ***
## veracityliar  0.08722    0.05176 12.55200   1.685    0.117    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr)
## veracitylir -0.570
```

## Emotional Features

The model selection procedure for emotional features suggested that the addition of the empathy subscales improved fit, but the addition of the emotional intelligence subscales did not.


```r
emotion_models[[4]]
```

```
## Data: data
## Models:
## model_1: criteria ~ veracity + (1 + veracity | ss) + (1 | sender)
## model_2: criteria ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + (1 + veracity | ss) + (1 | sender)
## model_3: criteria ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + r1g_st + r2g_st + r3g_st + r4g_st + (1 + veracity | ss) + (1 | sender)
##         npar    AIC    BIC  logLik deviance   Chisq Df Pr(>Chisq)   
## model_1    7 3353.2 3392.7 -1669.6   3339.2                         
## model_2   11 3343.5 3405.6 -1660.8   3321.5 17.6598  4   0.001438 **
## model_3   15 3347.3 3432.0 -1658.6   3317.3  4.2027  4   0.379262   
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

The IRI Fantasy subscale significantly predicts receivers reporting emotional features as judgment criteria. The effect is relatively small, however. A change of 1 point on the Fantasy subscale corresponds to a predicted increase of reporting 0.015 of an emotional feature criterion.


```r
summary(emotion_models[[2]])
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: criteria ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + (1 +  
##     veracity | ss) + (1 | sender)
##    Data: data
## 
## REML criterion at convergence: 3367
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.0377 -0.6197 -0.3180  0.7155  4.7669 
## 
## Random effects:
##  Groups   Name         Variance Std.Dev. Corr 
##  ss       (Intercept)  0.049757 0.22306       
##           veracityliar 0.001003 0.03166  -1.00
##  sender   (Intercept)  0.004177 0.06463       
##  Residual              0.260437 0.51033       
## Number of obs: 2098, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##                Estimate Std. Error         df t value Pr(>|t|)    
## (Intercept)   -0.004977   0.182170 150.859563  -0.027 0.978240    
## veracityliar  -0.026075   0.041190  12.097728  -0.633 0.538487    
## iri_pt         0.009455   0.005237 145.150387   1.805 0.073087 .  
## iri_ec        -0.005757   0.006099 145.145816  -0.944 0.346757    
## iri_fs         0.015199   0.004114 145.263192   3.694 0.000312 ***
## iri_pd        -0.003994   0.005088 145.227121  -0.785 0.433763    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr) vrctyl iri_pt iri_ec iri_fs
## veracitylir -0.119                            
## iri_pt      -0.468  0.000                     
## iri_ec      -0.307  0.000 -0.423              
## iri_fs      -0.260  0.000 -0.002 -0.232       
## iri_pd      -0.376  0.000  0.254 -0.347 -0.079
## optimizer (nloptwrap) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

## Expressive Indices

The model selection procedure suggested that neither empathy nor EI predicted receivers reporting expressive indices.


```r
expressive_models[[4]]
```

```
## Data: data
## Models:
## model_1: criteria ~ veracity + (1 + veracity | ss) + (1 | sender)
## model_2: criteria ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + (1 + veracity | ss) + (1 | sender)
## model_3: criteria ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + r1g_st + r2g_st + r3g_st + r4g_st + (1 + veracity | ss) + (1 | sender)
##         npar    AIC    BIC  logLik deviance  Chisq Df Pr(>Chisq)  
## model_1    7 3851.4 3890.9 -1918.7   3837.4                       
## model_2   11 3851.1 3913.2 -1914.5   3829.1 8.3014  4    0.08114 .
## model_3   15 3851.8 3936.6 -1910.9   3821.8 7.2500  4    0.12325  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```


```r
summary(expressive_models[[1]])
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: criteria ~ veracity + (1 + veracity | ss) + (1 | sender)
##    Data: data
## 
## REML criterion at convergence: 3844.8
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.2291 -0.6160 -0.2604  0.4857  5.3224 
## 
## Random effects:
##  Groups   Name         Variance Std.Dev. Corr 
##  ss       (Intercept)  0.09886  0.3144        
##           veracityliar 0.01350  0.1162   -1.00
##  sender   (Intercept)  0.02335  0.1528        
##  Residual              0.32556  0.5706        
## Number of obs: 2098, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##              Estimate Std. Error       df t value Pr(>|t|)    
## (Intercept)   0.41738    0.06561 16.64095   6.361 7.85e-06 ***
## veracityliar -0.08405    0.08592 12.29657  -0.978    0.347    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr)
## veracitylir -0.690
## optimizer (nloptwrap) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

## Paraverbal Aspects

The model selection procedure suggested that neither empathy nor EI predicted receivers reporting paraverbal aspects.


```r
paraverbal_models[[4]]
```

```
## Data: data
## Models:
## model_1: criteria ~ veracity + (1 + veracity | ss) + (1 | sender)
## model_2: criteria ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + (1 + veracity | ss) + (1 | sender)
## model_3: criteria ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + r1g_st + r2g_st + r3g_st + r4g_st + (1 + veracity | ss) + (1 | sender)
##         npar    AIC    BIC  logLik deviance  Chisq Df Pr(>Chisq)  
## model_1    7 4658.6 4698.2 -2322.3   4644.6                       
## model_2   11 4658.4 4720.5 -2318.2   4636.4 8.2346  4    0.08335 .
## model_3   15 4666.0 4750.7 -2318.0   4636.0 0.3991  4    0.98255  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```


```r
summary(paraverbal_models[[1]])
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: criteria ~ veracity + (1 + veracity | ss) + (1 | sender)
##    Data: data
## 
## REML criterion at convergence: 4653.8
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.0621 -0.7474 -0.3248  0.5796  4.6347 
## 
## Random effects:
##  Groups   Name         Variance Std.Dev. Corr 
##  ss       (Intercept)  0.116900 0.34191       
##           veracityliar 0.026536 0.16290  -0.56
##  sender   (Intercept)  0.004492 0.06702       
##  Residual              0.480281 0.69302       
## Number of obs: 2098, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##              Estimate Std. Error       df t value Pr(>|t|)    
## (Intercept)   0.68403    0.04335 31.78740  15.778   <2e-16 ***
## veracityliar -0.06879    0.04875 13.72396  -1.411     0.18    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr)
## veracitylir -0.619
```

# Additional materials

## Discarded models for Hypothesis 1

The initial model, with only veracity as a predictor.


```r
summary(model_base)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( logit )
## Formula: accuracy ~ veracity + (1 + veracity | ss) + (1 | sender)
##    Data: model_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2700.5   2734.4  -1344.2   2688.5     2093 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -1.8916 -0.8517 -0.4832  0.9071  2.0416 
## 
## Random effects:
##  Groups Name         Variance Std.Dev. Corr
##  ss     (Intercept)  0.003754 0.06127      
##         veracityliar 0.033344 0.18260  1.00
##  sender (Intercept)  0.517378 0.71929      
## Number of obs: 2099, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##              Estimate Std. Error z value Pr(>|z|)
## (Intercept)    0.2271     0.2794   0.813    0.416
## veracityliar  -0.5682     0.3962  -1.434    0.152
## 
## Correlation of Fixed Effects:
##             (Intr)
## veracitylir -0.704
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

The model adding the trait empathy measures.


```r
summary(model_emp)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( logit )
## Formula: accuracy ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + (1 +  
##     veracity | ss) + (1 | sender)
##    Data: model_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2700.5   2757.0  -1340.3   2680.5     2089 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.2392 -0.8589 -0.4616  0.8984  2.2249 
## 
## Random effects:
##  Groups Name         Variance  Std.Dev. Corr 
##  ss     (Intercept)  0.0001301 0.0114        
##         veracityliar 0.0417040 0.2042   -1.00
##  sender (Intercept)  0.5176627 0.7195        
## Number of obs: 2099, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##              Estimate Std. Error z value Pr(>|z|)  
## (Intercept)   0.22782    0.27951   0.815   0.4150  
## veracityliar -0.56862    0.39640  -1.434   0.1514  
## iri_pt        0.29240    0.12275   2.382   0.0172 *
## iri_ec       -0.10522    0.14263  -0.738   0.4607  
## iri_fs        0.07215    0.09609   0.751   0.4528  
## iri_pd        0.18455    0.11909   1.550   0.1212  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr) vrctyl iri_pt iri_ec iri_fs
## veracitylir -0.705                            
## iri_pt       0.002 -0.003                     
## iri_ec       0.000  0.001 -0.424              
## iri_fs       0.001 -0.001  0.000 -0.233       
## iri_pd       0.001 -0.002  0.258 -0.349 -0.077
```

## Discarded models for Hypothesis 2

Adding the interaction terms did not improve the fit of the model.


```r
summary(model_conf_ei_int)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( logit )
## Formula: accuracy ~ veracity + confidence * r1g_st + confidence * iri_pt +  
##     (1 + veracity | ss) + (1 | sender)
##    Data: model_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2689.0   2751.1  -1333.5   2667.0     2080 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.1722 -0.8648 -0.4501  0.8957  2.4041 
## 
## Random effects:
##  Groups Name         Variance Std.Dev. Corr 
##  ss     (Intercept)  0.001027 0.03205       
##         veracityliar 0.065677 0.25628  -1.00
##  sender (Intercept)  0.521373 0.72206       
## Number of obs: 2091, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##                    Estimate Std. Error z value Pr(>|z|)  
## (Intercept)        0.227668   0.280519   0.812   0.4170  
## veracityliar      -0.570497   0.398029  -1.433   0.1518  
## confidence        -0.002892   0.025230  -0.115   0.9088  
## r1g_st             0.080839   0.032254   2.506   0.0122 *
## iri_pt             0.213248   0.111075   1.920   0.0549 .
## confidence:r1g_st  0.006748   0.016270   0.415   0.6783  
## confidence:iri_pt -0.014779   0.056244  -0.263   0.7927  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr) vrctyl cnfdnc r1g_st iri_pt cnf:1_
## veracitylir -0.705                                   
## confidence   0.009 -0.010                            
## r1g_st       0.001 -0.005 -0.027                     
## iri_pt       0.001 -0.002 -0.043 -0.093              
## cnfdnc:r1g_ -0.005  0.004 -0.078  0.050  0.036       
## cnfdnc:r_pt -0.007 -0.001 -0.036  0.038 -0.056 -0.086
```

## Robustness checks for Hypothesis 1

The effect for EI Perceiving persists when removing the empathy variables.


```r
summary(model_ei_red)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( logit )
## Formula: accuracy ~ veracity + r1g_st + r2g_st + r3g_st + r4g_st + (1 +  
##     veracity | ss) + (1 | sender)
##    Data: model_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2694.8   2751.3  -1337.4   2674.8     2089 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.2658 -0.8587 -0.4520  0.8914  2.3954 
## 
## Random effects:
##  Groups Name         Variance Std.Dev. Corr 
##  ss     (Intercept)  0.001218 0.0349        
##         veracityliar 0.059765 0.2445   -1.00
##  sender (Intercept)  0.521739 0.7223        
## Number of obs: 2099, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##              Estimate Std. Error z value Pr(>|z|)   
## (Intercept)   0.22845    0.28062   0.814  0.41559   
## veracityliar -0.57066    0.39810  -1.433  0.15172   
## r1g_st        0.10417    0.03449   3.021  0.00252 **
## r2g_st       -0.09937    0.04003  -2.483  0.01304 * 
## r3g_st        0.04620    0.03467   1.333  0.18269   
## r4g_st        0.03210    0.03995   0.804  0.42162   
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr) vrctyl r1g_st r2g_st r3g_st
## veracitylir -0.705                            
## r1g_st       0.002 -0.005                     
## r2g_st      -0.002  0.003 -0.316              
## r3g_st       0.001 -0.002 -0.033 -0.174       
## r4g_st       0.001  0.000 -0.035 -0.331 -0.273
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

The coefficient for EI Perceiving remains significant when removing other predictors.


```r
summary(model_ei_per)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( logit )
## Formula: accuracy ~ veracity + r1g_st + (1 + veracity | ss) + (1 | sender)
##    Data: model_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2695.8   2735.4  -1340.9   2681.8     2092 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.0657 -0.8617 -0.4569  0.8974  2.1887 
## 
## Random effects:
##  Groups Name         Variance Std.Dev. Corr
##  ss     (Intercept)  0.00000  0.0000       
##         veracityliar 0.06359  0.2522    NaN
##  sender (Intercept)  0.52115  0.7219       
## Number of obs: 2099, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##              Estimate Std. Error z value Pr(>|z|)   
## (Intercept)   0.22779    0.28039   0.812  0.41656   
## veracityliar -0.57022    0.39784  -1.433  0.15177   
## r1g_st        0.08304    0.03219   2.580  0.00989 **
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr) vrctyl
## veracitylir -0.705       
## r1g_st       0.002 -0.005
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```
The negative coefficient for EI Using becomes nonsignificant when other predictors are removed.


```r
summary(model_ei_use)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( logit )
## Formula: accuracy ~ veracity + r2g_st + (1 + veracity | ss) + (1 | sender)
##    Data: model_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2701.8   2741.3  -1343.9   2687.8     2092 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -1.9389 -0.8561 -0.4823  0.9075  2.1434 
## 
## Random effects:
##  Groups Name         Variance Std.Dev. Corr
##  ss     (Intercept)  0.003304 0.05748      
##         veracityliar 0.031843 0.17845  1.00
##  sender (Intercept)  0.517101 0.71910      
## Number of obs: 2099, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##              Estimate Std. Error z value Pr(>|z|)
## (Intercept)   0.22709    0.27938   0.813    0.416
## veracityliar -0.56804    0.39609  -1.434    0.152
## r2g_st       -0.02827    0.03403  -0.831    0.406
## 
## Correlation of Fixed Effects:
##             (Intr) vrctyl
## veracitylir -0.705       
## r2g_st       0.000  0.001
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

Additionally, EI total scores and EI bifactor scores do not predict accuracy.


```r
summary(model_ei_sub)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( logit )
## Formula: accuracy ~ veracity + expg_st + strg_st + (1 + veracity | ss) +  
##     (1 | sender)
##    Data: model_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2701.9   2747.1  -1342.9   2685.9     2091 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.0288 -0.8601 -0.4769  0.9036  2.0841 
## 
## Random effects:
##  Groups Name         Variance Std.Dev. Corr
##  ss     (Intercept)  0.001478 0.03844      
##         veracityliar 0.036682 0.19153  1.00
##  sender (Intercept)  0.517517 0.71939      
## Number of obs: 2099, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##               Estimate Std. Error z value Pr(>|z|)
## (Intercept)  -0.384438   0.498513  -0.771    0.441
## veracityliar -0.568360   0.396247  -1.434    0.151
## expg_st       0.001265   0.003788   0.334    0.738
## strg_st       0.004515   0.003463   1.304    0.192
## 
## Correlation of Fixed Effects:
##             (Intr) vrctyl expg_s
## veracitylir -0.393              
## expg_st     -0.477 -0.002       
## strg_st     -0.424 -0.001 -0.407
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## Model is nearly unidentifiable: very large eigenvalue
##  - Rescale variables?
## Model is nearly unidentifiable: large eigenvalue ratio
##  - Rescale variables?
```


```r
summary(model_ei_tot)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( logit )
## Formula: accuracy ~ veracity + ttg_st + (1 + veracity | ss) + (1 | sender)
##    Data: model_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2700.6   2740.1  -1343.3   2686.6     2092 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.0004 -0.8562 -0.4778  0.9067  2.0778 
## 
## Random effects:
##  Groups Name         Variance Std.Dev. Corr
##  ss     (Intercept)  0.001688 0.04108      
##         veracityliar 0.041842 0.20455  1.00
##  sender (Intercept)  0.518347 0.71996      
## Number of obs: 2099, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##               Estimate Std. Error z value Pr(>|z|)
## (Intercept)  -0.274544   0.457413  -0.600    0.548
## veracityliar -0.568731   0.396638  -1.434    0.152
## ttg_st        0.004802   0.003467   1.385    0.166
## 
## Correlation of Fixed Effects:
##             (Intr) vrctyl
## veracitylir -0.429       
## ttg_st      -0.791 -0.003
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## Model is nearly unidentifiable: large eigenvalue ratio
##  - Rescale variables?
```

# Exploratory analyses

A reviewer requested an analysis of gender differences. 

Descriptively, it does seem as though women tend to score slightly higher on the
EI and empathy measures than men, but these tendencies are quite small. For the
empathy measures, three out of the four differences between men and women were 
statistically significant, for what it is worth.


```
## # A tibble: 2 × 9
##     sex mean_pt sd_pt mean_ec sd_ec mean_fs sd_fs mean_pd sd_pd
##   <dbl>   <dbl> <dbl>   <dbl> <dbl>   <dbl> <dbl>   <dbl> <dbl>
## 1     0    25.4  4.12    28.7  3.45    23.6  5.23    20.9  4.04
## 2     1    24.1  4.66    25.2  4.11    21.6  4.73    17.5  4.12
```


```r
emotion %>% 
    group_by(sex) %>% 
    summarise(
        mean_r1g = mean(r1g_st, na.rm = TRUE),
        sd_r1g   = sd(r1g_st, na.rm = TRUE),
        mean_r2g = mean(r2g_st, na.rm = TRUE),
        sd_r2g   = sd(r2g_st, na.rm = TRUE),
        mean_r3g = mean(r3g_st, na.rm = TRUE),
        sd_r3g   = sd(r3g_st, na.rm = TRUE),
        mean_r4g = mean(r4g_st, na.rm = TRUE),
        sd_r4g   = sd(r4g_st, na.rm = TRUE)
    )
```

```
## # A tibble: 2 × 9
##     sex mean_r1g sd_r1g mean_r2g sd_r2g mean_r3g sd_r3g mean_r4g sd_r4g
##   <dbl>    <dbl>  <dbl>    <dbl>  <dbl>    <dbl>  <dbl>    <dbl>  <dbl>
## 1     0     106.   15.6    100.    14.7     107.   14.5     104.   13.8
## 2     1     103.   13.2     99.1   12.8     108.   16.4     103.   13.8
```

There are many ways of approaching the question of whether accuracy varies as a 
function of gender. Here, we take the approach of fitting a simple model using 
only gender and veracity as fixed effects, with the same random effects 
structure as above, followed by a model that uses all the EI and empathy 
predictors as well.


```r
summary(gender_mod_1)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( logit )
## Formula: accuracy ~ veracity + sex + (1 + veracity | ss) + (1 | sender)
##    Data: model_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2701.1   2740.7  -1343.6   2687.1     2092 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -1.9163 -0.8543 -0.4739  0.9063  2.1145 
## 
## Random effects:
##  Groups Name         Variance Std.Dev. Corr
##  ss     (Intercept)  0.002351 0.04849      
##         veracityliar 0.036401 0.19079  1.00
##  sender (Intercept)  0.517619 0.71946      
## Number of obs: 2099, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##              Estimate Std. Error z value Pr(>|z|)
## (Intercept)    0.2635     0.2813   0.937    0.349
## veracityliar  -0.5684     0.3963  -1.434    0.152
## sex           -0.1211     0.1046  -1.158    0.247
## 
## Correlation of Fixed Effects:
##             (Intr) vrctyl
## veracitylir -0.700       
## sex         -0.112  0.002
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```


```r
summary(gender_mod_2)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( logit )
## Formula: accuracy ~ veracity + iri_pt + iri_ec + iri_fs + iri_pd + r1g_st +  
##     r2g_st + r3g_st + r4g_st + sex + (1 + veracity | ss) + (1 |      sender)
##    Data: model_data
## 
##      AIC      BIC   logLik deviance df.resid 
##   2697.2   2782.0  -1333.6   2667.2     2084 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.3706 -0.8605 -0.4334  0.8896  2.5034 
## 
## Random effects:
##  Groups Name         Variance Std.Dev. Corr 
##  ss     (Intercept)  0.004272 0.06536       
##         veracityliar 0.057151 0.23906  -1.00
##  sender (Intercept)  0.523666 0.72365       
## Number of obs: 2099, groups:  ss, 150; sender, 14
## 
## Fixed effects:
##              Estimate Std. Error z value Pr(>|z|)   
## (Intercept)   0.24466    0.28335   0.863  0.38790   
## veracityliar -0.57188    0.39874  -1.434  0.15151   
## iri_pt        0.27524    0.12414   2.217  0.02661 * 
## iri_ec       -0.13702    0.15391  -0.890  0.37334   
## iri_fs        0.06396    0.09789   0.653  0.51353   
## iri_pd        0.17857    0.12852   1.389  0.16470   
## r1g_st        0.10296    0.03454   2.981  0.00287 **
## r2g_st       -0.09906    0.04041  -2.451  0.01423 * 
## r3g_st        0.03678    0.03542   1.039  0.29902   
## r4g_st        0.03468    0.04261   0.814  0.41579   
## sex          -0.05068    0.11722  -0.432  0.66549   
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr) vrctyl iri_pt iri_ec iri_fs iri_pd r1g_st r2g_st r3g_st
## veracitylir -0.700                                                        
## iri_pt      -0.004 -0.003                                                 
## iri_ec      -0.031  0.001 -0.374                                          
## iri_fs      -0.009 -0.001  0.013 -0.202                                   
## iri_pd      -0.031 -0.002  0.221 -0.299 -0.051                            
## r1g_st      -0.008 -0.005 -0.019  0.012  0.092  0.023                     
## r2g_st      -0.011  0.003 -0.066  0.049  0.069  0.089 -0.294              
## r3g_st       0.007 -0.002 -0.094  0.163 -0.159 -0.065 -0.047 -0.173       
## r4g_st       0.006  0.000 -0.010 -0.287 -0.036  0.213 -0.036 -0.303 -0.281
## sex         -0.125  0.001  0.048  0.245  0.077  0.265  0.082  0.077 -0.053
##             r4g_st
## veracitylir       
## iri_pt            
## iri_ec            
## iri_fs            
## iri_pd            
## r1g_st            
## r2g_st            
## r3g_st            
## r4g_st            
## sex         -0.033
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

As can be seen in these results, neither model supports the notiion of gender
differences in accuracy.




