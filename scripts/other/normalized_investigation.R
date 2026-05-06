# Script to check normalized error by climate variable
# By: Peter Scully
# Date: 5/5/26

# Importing libraries
library(hector)
library(ggplot2)
theme_set(theme_bw(base_size = 14))
library(patchwork)
library(ggpubr)

# Setting up file paths
COMP_DATA_DIR <- file.path(here::here(), "comparison_data")
SCRIPTS_DIR <- file.path(here::here(), "scripts")
RESULTS_DIR <- file.path(here::here(), "results", "deliverable_plots")

CO2_PATH <- file.path(COMP_DATA_DIR,
                      "Supplementary_Table_UoM_GHGConcentrations-1-1-0_annualmeans_v23March2017.csv")
TEMP_PATH <-
  file.path(COMP_DATA_DIR,
            "HadCRUT.5.0.2.0.analysis.summary_series.global.annual.csv")

OHC_PATH <- file.path(COMP_DATA_DIR, "OHC_ensemble_Kuhlbrodt_etal_2022.csv")

INI_FILE <- system.file("input/hector_ssp245.ini", package = "hector")
PARAMS <- c(BETA(), Q10_RH(), DIFFUSIVITY(), ECS(), AERO_SCALE())
VARS <- c(GMST(), CONCENTRATIONS_CO2(), HEAT_FLUX())

source(file.path(SCRIPTS_DIR, "major_functions.R"))

nmse_run <- run_hector(ini_file = INI_FILE,
                    params = PARAMS,
                    vals = c(0.65, 1.76, 1.04, 2.33, 0.438),
                    yrs = 1750:2014,
                    vars = VARS)
nmse_run$scenario <- "Hector - NMSE w/ unc"

nmae_run <- run_hector(ini_file = INI_FILE,
                    params = PARAMS,
                    vals = c(0.59, 1.76, 1.04, 2.17, 0.411),
                    yrs = 1750:2014,
                    vars = VARS)
nmae_run$scenario <- "Hector - NMAE w/ unc"

co2_data <- get_co2_data(CO2_PATH)
T_data <- get_temp_data(TEMP_PATH, include_unc=T)
ohc_data <- get_ohc_data(OHC_PATH, include_unc=T)

co2_nmse <- get_var_mse(obs_data=co2_data,
                            hector_data=nmse_run,
                            var = CONCENTRATIONS_CO2(), 
                            yrs = c(1750, 1850:2014),
                            mse_fn = nmse)

T_nmse <- get_var_mse_unc(obs_data=T_data,
                            hector_data=nmse_run,
                            var = GMST(), 
                            yrs = c(1850:2014),
                            mse_fn = nmse_unc)

ohc_nmse <- get_var_mse_unc(obs_data=ohc_data,
                          hector_data=nmse_run,
                          var = "OHC", 
                          yrs = c(1957:2014),
                          mse_fn = nmse_unc)

print(co2_nmse)
print(T_nmse)
print(ohc_nmse)
print((co2_nmse + T_nmse + ohc_nmse) / 3)


co2_nmae <- get_var_mse(obs_data=co2_data,
                        hector_data=nmse_run,
                        var = CONCENTRATIONS_CO2(), 
                        yrs = c(1750, 1850:2014),
                        mse_fn = nmae)

T_nmae <- get_var_mse_unc(obs_data=T_data,
                          hector_data=nmse_run,
                          var = GMST(), 
                          yrs = c(1850:2014),
                          mse_fn = nmae_unc)

ohc_nmae <- get_var_mse_unc(obs_data=ohc_data,
                            hector_data=nmse_run,
                            var = "OHC", 
                            yrs = c(1957:2014),
                            mse_fn = nmae_unc)

print(co2_nmae)
print(T_nmae)
print(ohc_nmae)
print((co2_nmae + T_nmae + ohc_nmae) / 3)