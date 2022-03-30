import sys
import os
from Bio import SeqIO
import pandas as pd
import random

# ------- INPUT -------
# 1MB of sequence where local matches will be inserted into
query_file = snakemake.input.query
# Local matches sampled with certain error rate
match_file = snakemake.input.matches

# ------- OUTPUT ------- 
query_with_insertions_file = snakemake.output.query
ground_truth_file = snakemake.output.ground_truth

def check_file_exists(fn):
    if not os.path.exists(fn):
        raise SystemError("Error: File does not exist\n")
        
check_file_exists(match_file)
local_matches = list(SeqIO.parse(match_file, "fastq"))

check_file_exists(query_file)
query = list(SeqIO.parse(query_file, "fasta"))
assert (len(query) == 1),"Query contains more than one sequence, pick which one to insert to."

# Sort random positions
query_len = len(query[0].seq)
random.seed(42)
ran_ind_list = random.sample(range(query_len), len(local_matches))
ran_ind_list.sort()
# Shuffle local matches so that they would appear in the query in a random order
random.shuffle(local_matches) 

# Assign random location to each local match
for i in range(len(local_matches)):
    local_matches[i].description = ran_ind_list[i]
    

original_query = query[0].seq

id_list = []
position_list = []
length_list = []

# Insert local matches into query at random positions
query_with_insertions = original_query[0:local_matches[0].description]
insertion_length = 0
for i in range(0, len(local_matches)):
    match = local_matches[i]
    
    # Gather ground truth
    id_list.append(match.name)
    
    insertion_position = match.description + insertion_length
    position_list.append(insertion_position)    # position in the query
    length_list.append(len(match.seq))
    
    prefix = query_with_insertions[0:insertion_position]
    insertion = match.seq
    
    if (i < (len(local_matches) - 1)):
        postfix = original_query[match.description:local_matches[i+1].description]
    else:
        # Edge case: insert last local match
        postfix = original_query[local_matches[-1].description:]
    
    insertion_length += len(match.seq)
    query_with_insertions = prefix + insertion + postfix 

assert (len(query_with_insertions) - len(original_query)) == insertion_length,"Wrong length of sequence inserted."

# Write insertion query file
with open(query_with_insertions_file, 'w') as f:
    f.write('>1\n')
    f.write(str(query_with_insertions))
    
f.close()

# Create ground truth file
ground_truth = {'id':id_list,
                'position':position_list,
                'length':length_list}
 
ground_truth_df = pd.DataFrame(ground_truth)
ground_truth_df.to_csv(ground_truth_file, index=False, sep='\t')
ground_truth_df.head()