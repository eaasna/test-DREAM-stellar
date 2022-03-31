import pandas as pd

# ------- OUTPUT ------- 
table = snakemake.output[0]

error_rate_list = snakemake.config["er_rates"]

import pandas as pd

def get_float_er(er):
        if (er=="0"):          
                return "0.0"  
        return float(er[:1] + '.' + er[1:])
    
dfs = []
for rep in range(5):
    time_list = []
    missed_list = []
    for er in error_rate_list:
        benchmark_file = "benchmarks/stellar_" + str(rep) + "_" + er + ".txt"
        benchmark = pd.read_csv(benchmark_file, sep='\t')
        time_list.append(round(benchmark['s'].iloc[0], 3))
    
        evaluation_file = "evaluation/" + str(rep) + "_" + er + ".tsv"
        evaluation = pd.read_csv(evaluation_file, sep='\t', index_col = 0)
        missed_list.append(round(evaluation["missed"].iloc[0], 3))

    data = {'error_rate':error_rate_list,
            'time (sec)':time_list,
            'missed (%)':missed_list}
    
    dfs.append(pd.DataFrame(data))
    
# find mean of each time and missed cell over all repetitions
rep_mean = pd.concat(dfs).groupby(level=0).mean()
rep_mean["error_rate"] = dfs[0]["error_rate"].apply(get_float_er)

# change order of columns
cols = rep_mean.columns.tolist()
cols = cols[-1:] + cols[:-1]
rep_mean = rep_mean[cols]
rep_mean = rep_mean.round(2)
 
rep_mean.to_csv(table, sep='\t')
