library(testthat)
library(DashboardExport)

setwd('tests/testthat')
options(warn = -1)

# Individual tests
# devtools::install(quick = TRUE, upgrade = 'never')
# devtools::reload()

testthat::test_file('test-dashboardExport.R')
