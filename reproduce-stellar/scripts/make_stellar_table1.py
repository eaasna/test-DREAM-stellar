import pandas as pd


# ------- INPUT --------
n = snakemake.params.repeats

# ------- OUTPUT ------- 
table = snakemake.output[0]

error_rate_list = snakemake.params.error_rates

import pandas as pd

dfs = []
for rep in range(n):
    time_list = []
    missed_list = []
    for er in error_rate_list:
        benchmark_file = "benchmarks/stellar_rep" + str(rep) + "_e" + str(er) + ".txt"
        benchmark = pd.read_csv(benchmark_file, sep='\t')
        time_list.append(round(benchmark['s'].iloc[0], 3))
    
        evaluation_file = "evaluation/rep" + str(rep) + "_e" + str(er) + ".tsv"
        evaluation = pd.read_csv(evaluation_file, sep='\t', index_col = 0)
        missed_list.append(round(evaluation["missed"].iloc[0], 3))

    data = {'error_rate':error_rate_list,
            'time (sec)':time_list,
            'missed (%)':missed_list}
    
    dfs.append(pd.DataFrame(data))
    
# find mean of each time and missed cell over all repetitions
rep_mean = pd.concat(dfs).groupby(level=0).mean()
rep_mean = rep_mean.round(3)
rep_mean.to_csv(table, sep='\t')
