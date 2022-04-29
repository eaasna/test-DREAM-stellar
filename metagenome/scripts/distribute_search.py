import numpy as np
import pandas as pd
from Bio import SeqIO

#------------ INPUT ------------ 
rep = snakemake.wildcards.rep
er = snakemake.wildcards.er

# query_file = "../10Mb/rep" + str(rep) + "/queries/e" + str(er) + ".fastq"
# search_file = "../10Mb/rep" + str(rep) + "/search/e" + str(er) + ".out"
query_file = snakemake.input.queries
search_file = snakemake.input.search_out

bins = snakemake.config["ibf_bins"]
bin_int_list = list(range(bins))
bin_str_list = [str(b).zfill(len(str(bins))) for b in bin_int_list]

#------------ OUTPUT ------------
# output_prefix = "../10Mb/rep" + str(rep) + "/queries/"
output_prefix = snakemake.params.out_prefix

# tidy match files
matches = pd.read_csv(search_file, sep='\t', header=None)
matches.columns = ["read_id", "matches"]
matches = matches.assign(match_cols=matches['matches'].str.split(',')).explode('matches')
matches = matches.drop(["matches"], axis = 1)
matches = matches.explode("match_cols")
matches.columns = ["read_id", "bin_id"]
matches = matches.replace(r'^\s*$', np.nan, regex=True).dropna() # drop empty rows
matches = matches.reset_index(drop = True)
matches["bin_id"] = pd.to_numeric(matches["bin_id"])

# open all output bin query files 
bin_query_files = [open((output_prefix + 'bin_{}_e' + str(er) + ".fasta").format(b), 'w') for b in bin_str_list]

queries = list(SeqIO.parse(query_file, "fastq"))
# scan over query file once
for query in queries:
    read_matches = matches[matches["read_id"]==int(query.name)]
    for index, match in read_matches.iterrows():
        SeqIO.write(query, bin_query_files[match["bin_id"]], "fasta")
    
for f in bin_query_files:
    f.close()

# remove file if no queries for bin
# import subprocess
# remove_empty_files = "find . -type f -empty -delete"
# subprocess.call(remove_empty_files, shell=True, cwd='queries')

