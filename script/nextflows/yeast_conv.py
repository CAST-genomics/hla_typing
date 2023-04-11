#!/usr/bin/python
from Bio.SeqIO import parse

if __name__ == "__main__":
    with open("./examples/data/reference/yeast_regions.bed", "w") as bed:
        for record in parse("/home/drew/models/yeast_cram/gemBS_example/reference/sacCer3.fa", "fasta"):
            print(record.id, 0, len(record.seq), sep="\t", file=bed)

