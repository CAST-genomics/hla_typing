library(data.table)

args = commandArgs(trailingOnly=TRUE)

result_file  =            args[[1]]
alleles_file =            args[[2]]
mean_cov     = as.numeric(args[[3]])
read_len     = as.numeric(args[[4]])

hla     = fread(result_file , sep = "\t", header = TRUE , data.table = FALSE)
alleles = fread(alleles_file, sep = " " , header = FALSE, data.table = FALSE)

colnames(hla    ) = tolower(colnames(hla))
colnames(alleles) = c("id", "type")
alleles$id        = paste("HLA", alleles$id, sep = ":")
hla               = merge(hla, alleles)
hla$gene          = unlist(lapply(hla$type, function(x){unlist(strsplit(x, "\\*"))[[1]]}))
hla$depth         = hla$z * read_len * 2 / hla$length

find_allele = function(gene, hla, mean_cov = 30)
{
    #threshold = mean_cov * 0.2 # original
    threshold = mean_cov * 0.1
    hla       = hla[ hla$gene == gene,]
    hla       = hla[ order(hla$z, decreasing = TRUE), ]
    out       = data.frame(gene = gene, type1 = "", type2 = "")
    
    if(nrow(hla[ hla$depth >= threshold,]) > 0)
    {
        if(nrow(hla[ hla$depth >= threshold,]) == 1)
        {
            if(hla[1, "depth"] >= 2 * threshold)
            {
                # homozygous
                out[1, c("type1", "type2")] = hla[1, "type"]
            }else
            {
                # heterozygous, second allele unknown
                out[1, "type1"] = hla[1, "type"]
            }
        }else
        {
            if(hla[1, "depth"] >= 2 * hla[2, "depth"])
            {
                # homozygous
                out[1, c("type1", "type2")] = hla[1, "type"]
            }else
            {
                # heterozygous
                out[1, "type1"] = hla[1, "type"]
                out[1, "type2"] = hla[2, "type"]
            }
        }
    }else
    {
        # no allele is called
    }
    
    return(list(out, hla))
}

types_list  = lapply(sort(unique(hla$gene)), function(gene){find_allele(gene, hla, mean_cov)})
types_final = as.data.frame(rbindlist(lapply(types_list, function(x){x[[1]]})), stringsAsFactors = FALSE)
types_all   = as.data.frame(rbindlist(lapply(types_list, function(x){x[[2]]})), stringsAsFactors = FALSE)

fwrite(types_final, sub("result.txt$", "hla_types.txt"    , result_file), sep = "\t", col.names = TRUE, row.names = FALSE)
fwrite(types_all  , sub("result.txt$", "hla_types_all.txt", result_file), sep = "\t", col.names = TRUE, row.names = FALSE)
