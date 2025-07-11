# Script to calculate OHC RMSE for all runs (since we didn't calculate it
# automatically for most runs)
# Author: Peter Scully
# Date: 7/1/24

### Constants and Imports ###

# Importing libraries
library(hector)
library(ggplot2)
theme_set(theme_bw(base_size = 20))

# Setting up file paths
COMP_DATA_DIR <- file.path(here::here(), "comparison_data")
SCRIPTS_DIR <- file.path(here::here(), "scripts")
RESULTS_DIR <- file.path(here::here(), "results")

OHC_PATH <- file.path(COMP_DATA_DIR, "OHC_ensemble_Kuhlbrodt_etal_2022.csv")

INI_FILE <- system.file("input/hector_ssp245.ini", package = "hector")
PARAMS <- c(BETA(), Q10_RH(), DIFFUSIVITY(), ECS(), AERO_SCALE())

OUTPUT <- file.path(RESULTS_DIR, "OHC_RMSE.txt")


source(file.path(SCRIPTS_DIR, "major_functions.R"))

### Getting observational data ###
obs_data <- get_ohc_data(OHC_PATH, include_unc = T)

### Running Hector ###
# Default (and initial smoothing) Results [Exp. 1-4]
default_data <- run_hector(ini_file = INI_FILE, 
                           params = NULL,
                           vals = NULL,
                           yrs = 1750:2014, 
                           vars = HEAT_FLUX())
default_data$scenario <- "Hector - Default"

# NMSE 3-Parameter Results [Exp.5-9]
exp5_9A <- run_hector(ini_file = INI_FILE,
                      params = PARAMS,
                      vals = c(0.268, 2.64, 2.2, 3, 1),
                      yrs = 1750:2014,
                      vars = HEAT_FLUX())
exp5_9A$scenario <- "Hector - NMSE"

exp5B <- run_hector(ini_file = INI_FILE,
                    params = PARAMS,
                    vals = c(0, 1.5, 2.6, 3, 1),
                    yrs = 1750:2014,
                    vars = HEAT_FLUX())
exp5B$scenario <- "Hector - NMSE \nBig Box"

exp6B <- run_hector(ini_file = INI_FILE,
                    params = PARAMS,
                    vals = c(0, 1.58, 2.6, 3, 1),
                    yrs = 1750:2014,
                    vars = HEAT_FLUX())
exp6B$scenario <- "Hector - NMSE, Smoothing (k = 3) \nBig Box"

exp8B <- run_hector(ini_file = INI_FILE,
                    params = PARAMS,
                    vals = c(0, 1.95, 2.6, 3, 1),
                    yrs = 1750:2014,
                    vars = HEAT_FLUX())
exp8B$scenario <- "Hector - NMSE, Smoothing (k = 10) \nBig Box"

exp9B <- run_hector(ini_file = INI_FILE,
                    params = PARAMS,
                    vals = c(0.0, 1.08, 2.6, 3, 1),
                    yrs = 1750:2014,
                    vars = HEAT_FLUX())
exp9B$scenario <- "Hector - NMSE w/ unc \nBig Box"


# Optimizing S, Alpha [Exp. 10-11]
exp10A <- run_hector(ini_file = INI_FILE,
                     params = PARAMS,
                     vals = c(0.268, 2.64, 2.4, 3.97, 1),
                     yrs = 1750:2014,
                     vars = HEAT_FLUX())
exp10A$scenario <- "Hector - NMSE w/ unc \nTuning S"

exp10B <- run_hector(ini_file = INI_FILE,
                     params = PARAMS,
                     vals = c(0.006, 1, 2.6, 3.16, 1),
                     yrs = 1750:2014,
                     vars = HEAT_FLUX())
exp10B$scenario <- "Hector - NMSE w/ unc \nBig Box, Tuning S"

exp11A <- run_hector(ini_file = INI_FILE,
                     params = PARAMS,
                     vals = c(0.564, 1.76, 2.2, 2.87, 0.487),
                     yrs = 1750:2014,
                     vars = HEAT_FLUX())
exp11A$scenario <- "Hector - NMSE w/ unc \nTuning S, Alpha"

exp11B <- run_hector(ini_file = INI_FILE,
                     params = PARAMS,
                     vals = c(0.524, 0.88, 2, 2.94, 0.493),
                     yrs = 1750:2014,
                     vars = HEAT_FLUX())
exp11B$scenario <- "Hector - NMSE w/ unc \nBig Box, Tuning S, Alpha"

# Optimizing for OHC & Further Refinements [Exp. 12-16]
exp12 <- run_hector(ini_file = INI_FILE,
                    params = PARAMS,
                    vals = c(0.649, 1.76, 1.04, 2.39, 0.439),
                    yrs = 1750:2014,
                    vars = HEAT_FLUX())
exp12$scenario <- "Hector - NMSE w/ unc, incl. OHC \nTuning S, Alpha"

exp13 <- run_hector(ini_file = INI_FILE,
                    params = PARAMS,
                    vals = c(0.53, 2.31, 1.04, 2.83, 1.405),
                    yrs = 1750:2014,
                    vars = HEAT_FLUX())
exp13$scenario <- "Hector - MVSSE, incl. OHC \nTuning S, Alpha"

exp14A <- run_hector(ini_file = INI_FILE,
                     params = PARAMS,
                     vals = c(0.732, 1.76, 1.04, 3, 0.581),
                     yrs = 1750:2014,
                     vars = HEAT_FLUX())
exp14A$scenario <- "Hector - NMSE w/ unc, incl. OHC \nTuning Alpha"

exp14B <- run_hector(ini_file = INI_FILE,
                     params = PARAMS,
                     vals = c(0.883, 0.88, 0.841, 3, 0.462),
                     yrs = 1750:2014,
                     vars = HEAT_FLUX())
exp14B$scenario <- "Hector - NMSE w/ unc, incl. OHC \nBig Box, Tuning Alpha"

exp15 <- run_hector(ini_file = INI_FILE,
                    params = PARAMS,
                    vals = c(0.57, 2.49, 1.06, 3.14, 1.08),
                    yrs = 1750:2014,
                    vars = HEAT_FLUX())
exp15$scenario <- "Hector - MAE w/ unc, incl. OHC \nTuning S, Alpha"

exp16 <- run_hector(ini_file = INI_FILE,
                    params = PARAMS,
                    vals = c(0.59, 1.76, 1.04, 2.17, 0.411),
                    yrs = 1750:2014,
                    vars = HEAT_FLUX())
exp16$scenario <- "Hector - NMAE w/ unc, incl. OHC \nTuning S, Alpha"

exp17 <- run_hector(ini_file = INI_FILE,
                    params = PARAMS,
                    vals = c(0.53, 1.86, 1.26, 2.87, 1.33),
                    yrs = 1750:2014,
                    vars = HEAT_FLUX())
exp17$scenario <- "Hector - MSE w/ unc, incl. OHC \nTuning S, Alpha"

exp18 <- run_hector(ini_file = INI_FILE,
                    params = PARAMS,
                    vals = c(0.55, 1.81, 1.19, 2.31, 0.93),
                    yrs = 1750:2014,
                    vars = HEAT_FLUX())
exp18$scenario <- "Hector - MSE w/o unc, incl. OHC \nTuning S, Alpha"

co2_only <- run_hector(ini_file = INI_FILE,
                       params = PARAMS,
                       vals = c(0.35, 2.51, 1.14, 4.29, 2.63),
                       yrs = 1750:2014,
                       vars = HEAT_FLUX())
co2_only$scenario <- "Hector - optimized for only CO2"

T_only <- run_hector(ini_file = INI_FILE,
                       params = PARAMS,
                       vals = c(0.65, 1.76, 1.04, 2.50, 0.44),
                       yrs = 1750:2014,
                       vars = HEAT_FLUX())
T_only$scenario <- "Hector - optimized for only T"

OHC_only <- run_hector(ini_file = INI_FILE,
                     params = PARAMS,
                     vals = c(0.54, 1.76, 1.27, 2.96, 1.08),
                     yrs = 1750:2014,
                     vars = HEAT_FLUX())
OHC_only$scenario <- "Hector - optimized for only OHC"

# Calculating OHC RMSE
all_exp <- list(default_data, 
             exp5_9A, exp5B, exp6B, exp8B, exp9B,  # NMSEs
             exp10A, exp10B,                       # Add S
             exp11A, exp11B,                       # Add alpha
             exp12,                                # Add OHC, Mat Diff
             exp13,                                # Try MVSSE
             exp14A, exp14B,                       # Try remove S
             exp15, exp16,                         # Try MAE/NMAE
             exp17, exp18,                         # Try MSE w/ and w/o unc
             co2_only, T_only, OHC_only)                         

# TODO: clean up this output sorry

scenarios <- sapply(all_exp, (function (x) x$scenario[1]))

# MSE w/ unc
mse_unc <- sapply(all_exp, get_var_mse_unc, 
                  obs_data = obs_data, 
                  var = "OHC", 
                  yrs = 1957:2014, 
                  mse_fn = mse_unc)

# MSE w/o unc
mse <- sapply(all_exp, get_var_mse,
              obs_data = obs_data, var = "OHC", yrs = 1957:2014, mse_fn = mse)

rmse_unc <- sqrt(mse_unc)
rmse <- sqrt(mse)

# Output as dataframe
output <- data.frame(scenarios, mse_unc, mse, rmse_unc, rmse)
output
