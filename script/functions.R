# Load packages

suppressPackageStartupMessages(library(colorspace))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(plyr      ))
suppressPackageStartupMessages(library(dplyr     ))
suppressPackageStartupMessages(library(optparse  ))

# General Variables
chrom    = 6
from     = 25000001
to       = 34000001
coord    = paste0(chrom, ":", from, "-", to)
vcf_snps = paste(getwd(), "input/vcf", "mhc.vcf.gz" , sep = "/")
vcf_chr6 = paste(getwd(), "input/vcf", "chr6.vcf.gz", sep = "/")

# Functions

add_rownames = function(x) # add rownames to fread
{
	rownames(x) = x[,1]
	x[,1]       = NULL
	return(x)
}

psize = function (w, h) 
{
    options(repr.plot.height = h, repr.plot.width = w)
}
