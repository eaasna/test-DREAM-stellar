import pandas as pd

# ------- INPUT ------- 
# stellar_out_file = "../stellar/" + er + ".gff"
stellar_out_file = snakemake.input.stellar

#truth_file = "../ground_truth/" + er + ".tsv"
truth_file = snakemake.input.truth

# ------- OUTPUT ------- 
#evaluation_file = "../evaluation/" + er + ".txt"
evaluation_file = snakemake.output[0]

# ------- preprocess stellar output ------- 
stellar_df = pd.read_csv(stellar_out_file, sep='\t', header=None)
stellar_df.columns = ["DNAME", "stellar", "eps-matches", "DBEGIN", "DEND", "PERCID", "DSTRAND", ".", "ATTRIBUTES"]

interesting_attributes = stellar_df['ATTRIBUTES'].str.split(';',expand=True).drop(labels = [0, 2, 3], axis = 1)
interesting_attributes = interesting_attributes[1].str.split('=', expand=True).drop(labels=0, axis = 1)
interesting_attributes = interesting_attributes[1].str.split(',', expand=True)
interesting_attributes.columns = ['QBEGIN', 'QEND']

stellar_df = stellar_df.drop(labels = ["stellar", "eps-matches", "DSTRAND", "ATTRIBUTES"], axis = 1)
stellar_df = stellar_df.join(interesting_attributes)
stellar_df["QBEGIN"] = pd.to_numeric(stellar_df["QBEGIN"])
stellar_df["QEND"] = pd.to_numeric(stellar_df["QEND"])

# convert stellar 1-based indices to 0-based
stellar_df["QBEGIN"] = stellar_df.apply(lambda row: row.QBEGIN - 1, axis=1)
stellar_df["QEND"] = stellar_df.apply(lambda row: row.QEND - 1, axis=1)

sorted_stellar = stellar_df.sort_values('QBEGIN')
sorted_stellar["length"] = sorted_stellar.apply(lambda row: row.DEND - row.DBEGIN, axis=1)

# ------- preprocess ground truth -------
truth_df = pd.read_csv(truth_file, sep='\t')
truth_df['QEND'] =  truth_df.apply(lambda row: row.position + row.length, axis=1)
truth_df.rename(columns = {'position':'QBEGIN'}, inplace = True)


# ------- evaluate results -------
true_match_count = 0
overlap_list = []

for t_ind in range(len(truth_df["id"])):
    truth_range = range(truth_df.iloc[t_ind]['QBEGIN'],truth_df.iloc[t_ind]['QEND'])
    for s_ind in range(len(sorted_stellar['DNAME'])):
        stellar_range = range(sorted_stellar.iloc[s_ind]['QBEGIN'],sorted_stellar.iloc[s_ind]['QEND'])
        
        # find overlap between two ranges
        overlap_range = range(max(truth_range[0], stellar_range[0]), min(truth_range[-1], stellar_range[-1])+1)
        if (len(overlap_range) >= 40):
            true_match_count += 1
            overlap_list.append(len(overlap_range))

total_match_count = len(truth_df["id"]) 
with open(evaluation_file, 'w') as f:
    f.write('Total matches: ' + str(total_match_count) + '\n')
    f.write('Matches found by Stellar: ' + str(true_match_count) + '\n')
    f.write('Accuracy: ' + str(min(true_match_count/total_match_count, 1.0)))
            
f.close()