# Script to compare future temperatures for different Hector parameterizations
# Author: Peter Scully
# Date: 9/10/24

### Constants and Imports ###

# Importing libraries
library(hector)
library(ggplot2)
theme_set(theme_bw(base_size = 20))

# Setting up file paths
COMP_DATA_DIR <- file.path(here::here(), "comparison_data")
SCRIPTS_DIR <- file.path(here::here(), "scripts")
RESULTS_DIR <- file.path(here::here(), "results", "deliverable_plots")

INI_PREFIX <- system.file("input/hector_ssp", package = "hector") #
PARAMS <- c(BETA(), Q10_RH(), DIFFUSIVITY(), ECS(), AERO_SCALE())

OUTPUT <- file.path(RESULTS_DIR, "tech_note_future_T_comparison.jpeg")


source(file.path(SCRIPTS_DIR, "major_functions.R"))


# Running Hector (modified from calc_table_metrics in major_functions.R)

# Setting up variables
future_yrs <- 1850:2100
future_vars <- GLOBAL_TAS() # Using global_tas to match IPCC AR6 future metrics

# Getting the names of each scenario file
scenarios <- c("119", "245", "585")
scenario_names <- paste("input/hector_ssp", scenarios, ".ini", sep = "")
scenario_files <- system.file(scenario_names, package = "hector")

# Setting up results data frame
future_results <- data.frame(matrix(nrow = 0, ncol = 5))
colnames(future_results) <- c("scenario", "variable", "value", "units", "run")

# Doing default run
for (scen_counter in 1:length(scenario_files)) {
  # Adding default data
  default_data <- run_hector(ini_file = scenario_files[scen_counter],
                          params = NULL,
                          vals = NULL,
                          yrs = future_yrs,
                          vars = future_vars)
  default_data$scenario <- paste("ssp", scenarios[scen_counter], sep="")
  default_data$run <- "Default Parameterization"
  
  # Adding data from each of the main runs
  mse_data <- run_hector(ini_file = scenario_files[scen_counter],
                      params = PARAMS,
                      vals = c(0.55, 1.81, 1.19, 2.31, 0.928),
                      yrs = future_yrs,
                      vars = future_vars)
  mse_data$scenario <- paste("ssp", scenarios[scen_counter], sep="")
  mse_data$run <- "MSE"
  
  mae_data <- run_hector(ini_file = scenario_files[scen_counter],
                      params = PARAMS,
                      vals = c(0.56, 1.76, 1.04, 2.35, 0.865),
                      yrs = future_yrs,
                      vars = future_vars)
  mae_data$scenario <- paste("ssp", scenarios[scen_counter], sep="")
  mae_data$run <- "MAE" 
  
  nmse_data <- run_hector(ini_file = scenario_files[scen_counter],
                      params = PARAMS,
                      vals = c(0.65, 1.76, 1.04, 2.33, 0.438),
                      yrs = future_yrs,
                      vars = future_vars)
  nmse_data$scenario <- paste("ssp", scenarios[scen_counter], sep="")
  nmse_data$run <- "NMSE w/ unc"
  
  nmae_data <- run_hector(ini_file = scenario_files[scen_counter],
                          params = PARAMS,
                          vals = c(0.59, 1.76, 1.04, 2.17, 0.411),
                          yrs = future_yrs,
                          vars = future_vars)
  nmae_data$scenario <- paste("ssp", scenarios[scen_counter], sep="")
  nmae_data$run <- "NMAE w/ unc"
  
  mvsse_data <- run_hector(ini_file = scenario_files[scen_counter],
                      params = PARAMS,
                      vals = c(0.53, 2.31, 1.04, 2.83, 1.405),
                      yrs = future_yrs,
                      vars = future_vars)
  mvsse_data$scenario <- paste("ssp", scenarios[scen_counter], sep="")
  mvsse_data$run <- "MVSSE"
  
  
  
  # Adding both data frames to results data frame
  future_results <- rbind(future_results, default_data, mse_data, mae_data, nmse_data, 
                          nmae_data, mvsse_data)
}

# Plot results
ggplot(data = future_results, aes(x = year, y = value, color = run)) + 
  geom_line(linewidth = 1.0) +
  facet_wrap(~ scenario) +
  
  # Cleaning up plot
  scale_color_manual(name = "",
                     values = c("orange", "skyblue", "blue", "#009E73", "#CC79A7", "snow4")) + 
  theme(legend.text = element_text(size = 15), 
        legend.key.height = unit(2, "cm")) +
  ylab("Temperature Anomaly (\u00B0C)") +
  xlab("Year")
ggsave(OUTPUT, width = 20, height = 10)