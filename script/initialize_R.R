# Andrew Hodges, PhD
# 12 Aug 2022
# Purpose: initialize dependencies/installations

# Depends:

install.packages("colorspace")
install.packages("data.table")
install.packages("plyr")
install.packages("dplyr")
install.packages("optparse")
install.packages("bit64")

if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install()
BiocManager::install("rhdf5")

#Note: to install reshape2 correctly, this must be done from conda as follows:
install.packages("reshape2", dependencies=TRUE, INSTALL_opts = c('--no-lock'))
# # OR:
# conda install -c conda-forge r-reshape2


