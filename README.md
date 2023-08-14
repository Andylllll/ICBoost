# ICBoost

This repository contains python and R implementation of the algorithms proposed in ICBoost.

## Description

This study introduces a survival algorithm that integrates regression trees and ensembles for interval-censored data (ICBoost). Due to the interval-censored characteristics of the data, accurate prediction of survival is challenging. Therefore, in this paper， an unbiased transformation method that utilizes kernel density estimation is proposed to impute the failure time and predict survival. 


## Requirements

It is required to install the following dependencies in order to be able to run the code

- [Anaconda3](https://www.anaconda.com/products/individual)  
- [python 3](https://www.python.org/downloads/)  
- [sklearn](https://pypi.org/project/sklearn/0.0/)
- [numpy 1.19.1](https://pypi.org/project/numpy/1.19.1/)
- [xgboost 1.6.1](https://pypi.org/project/xgboost/1.6.1/)
- [glmnet 4.1.2](https://pypi.org/project/glmnet/)
- [R>=4.1.0](https://www.r-project.org/)  
- [reticulate](https://cran.r-project.org/web/packages/reticulate)
  
  

## Data

The data used in this research are collected from R package bayesSurv and ADNIMERGE.


## The describe of the program

The program is divided into three sections saved in this repository.

1) untrans.R: an r code for some basic unbiased transformation functions.

2) XGBt.py: a python code for training the XGBoost model with grid search method.

3) Main.R: The code is used to reproduce the prediction results.


