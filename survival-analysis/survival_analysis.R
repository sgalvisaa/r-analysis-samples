# =============================================================================
# Survival Analysis: Kaplan-Meier and Cox Proportional Hazards Modeling
# Author: Stephanie Galvis
#
# Dataset: Time-to-event survival data from Rice University STAT553 course repository
#   URL: https://www.stat.rice.edu/~sneeley/STAT553/Datasets/survivaldata.txt
#   Format: Stanford heart transplant data (69 patients): age at transplant,
#   survival status (1 = dead, 0 = alive), survival time in days
#
# Analysis Overview:
#   1. Data loading and cleaning
#   2. Kaplan-Meier survival curve estimation and visualization by group
#   3. Cox proportional hazards model to estimate hazard ratios and p-values
#   4. Interpretation of concordance index, confidence intervals, and log-rank test
#
# Note: Data is loaded directly from a public URL; no local files required.
# =============================================================================

library(survival)

# -----------------------------------------------------------------------------
# 1. Load and Clean Survival Data
# -----------------------------------------------------------------------------

data_url <- "https://www.stat.rice.edu/~sneeley/STAT553/Datasets/survivaldata.txt"

# The file starts with 11 lines of description, then 69 heart transplant patients,
# followed by other datasets. Read only the 69 patient rows.
survival_data <- read.table(data_url, skip = 11, nrows = 69,
                            col.names = c("Age", "Status", "Time"))

# Check the structure before analyzing
str(survival_data)

# Split patients into two age groups at transplant (50 and older vs under 50)
survival_data$Group <- factor(
  ifelse(survival_data$Age >= 50, "Age 50+", "Under 50")
)

cat("Sample sizes by group:\n")
print(table(survival_data$Group))
cat("Total events:", sum(survival_data$Status), "\n\n")

# -----------------------------------------------------------------------------
# 2. Kaplan-Meier Survival Analysis
# -----------------------------------------------------------------------------

# Create a Surv object encoding both time-to-event and censoring status
surv_obj <- Surv(time = survival_data$Time, event = survival_data$Status)

# Fit stratified KM curves by risk group
km_fit <- survfit(surv_obj ~ Group, data = survival_data)

# Plot KM curves with group-specific colors and a reference legend
plot(
  km_fit,
  col   = c("steelblue", "firebrick"),
  lwd   = 2,
  xlab  = "Time (days)",
  ylab  = "Survival Probability",
  main  = "Kaplan-Meier Survival Curves by Age Group"
)
legend(
  "topright",
  legend = levels(survival_data$Group),
  col    = c("steelblue", "firebrick"),
  lwd    = 2
)

# Print KM summary statistics (median survival times and confidence intervals)
cat("Kaplan-Meier Summary:\n")
print(km_fit)

# -----------------------------------------------------------------------------
# 3. Cox Proportional Hazards Model
# -----------------------------------------------------------------------------

# Fit Cox PH model with risk group as the single predictor
cox_model <- coxph(surv_obj ~ Group, data = survival_data)

cat("\nCox Proportional Hazards Model Summary:\n")
print(summary(cox_model))

# Extract and display key model outputs
cox_summary <- summary(cox_model)

cat("\n--- Key Outputs ---\n")
cat("Hazard Ratio (exp(coef)):", round(cox_summary$conf.int[1, "exp(coef)"], 4), "\n")
cat("95% CI: [",
    round(cox_summary$conf.int[1, "lower .95"], 4), ",",
    round(cox_summary$conf.int[1, "upper .95"], 4), "]\n")
cat("Wald test p-value:", round(cox_summary$waldtest["pvalue"], 4), "\n")
cat("Log-rank test p-value:", round(cox_summary$sctest["pvalue"], 4), "\n")
cat("Concordance index:", round(cox_summary$concordance["C"], 4), "\n")

cat("\nAnalysis complete.\n")
