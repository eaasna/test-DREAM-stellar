import numpy as np
import pandas as pd
from Bio import SeqIO

#------------ INPUT ------------ 
#query_file = "../100kb/queries/rep0_e0.025.fastq"
query_file = snakemake.input.queries
#search_file = "../100kb/search/rep0_e0.025.out"
search_file = snakemake.input.search_out

bins = snakemake.config["ibf_bins"]
rep = snakemake.wildcards.rep
er = snakemake.wildcards.er

#------------ OUTPUT ------------ 
#output_prefix = "rep" + str(rep) + "/queries/"
output_prefix = snakemake.params.out_prefix

# tidy match files
matches = pd.read_csv(search_file, sep='\t', header=None)
matches.columns = ["read_id", "matches"]
matches[['read_id','meta']] = matches['read_id'].str.split(' ',expand=True)
matches = matches.assign(match_cols=matches['matches'].str.split(',')).explode('matches')
matches = matches.drop(["matches", "meta"], axis = 1)
matches = matches.explode("match_cols")
matches.columns = ["read_id", "bin_id"]
matches = matches.replace(r'^\s*$', np.nan, regex=True).dropna() # drop empty rows
matches = matches.reset_index(drop = True)
matches["bin_id"] = pd.to_numeric(matches["bin_id"])

# write filtered bin queries into separate files
queries = list(SeqIO.parse(query_file, "fastq"))
for bin_id in list(range(bins)):
    bin_matches = matches[matches["bin_id"]==bin_id]
    seg_out_file = output_prefix + "seg" + str(bin_id) + "_e" + str(er) + ".fasta"
    with open(seg_out_file, "w") as output_handle:
        for query in queries:
            if (query.name in list(bin_matches["read_id"])):
                SeqIO.write(query, output_handle, "fasta")

# remove file if no queries for bin
# import subprocess
# remove_empty_files = "find . -type f -empty -delete"
# subprocess.call(remove_empty_files, shell=True, cwd='queries')

