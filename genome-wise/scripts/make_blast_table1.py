import pandas as pd


# ------- INPUT --------
#n = 1
#prefix = "blast"
n = snakemake.params.repeats

# ------- OUTPUT ------- 
table = snakemake.output[0]
#table = "blast_table1_test.tsv"

import pandas as pd

dfs = []
for rep in range(n):
    search_time_list = []
    build_time_list = []
    #missed_list = []
    total_match_list = []
    search_benchmark_file = "benchmarks/blast.txt"
    search_benchmark = pd.read_csv(search_benchmark_file, sep='\t')
    search_time_list.append(round(search_benchmark['s'].iloc[0], 3))

    build_benchmark_file = "benchmarks/blast_build.txt"
    print(build_benchmark_file)
    build_benchmark = pd.read_csv(build_benchmark_file, sep='\t')
    build_time_list.append(round(build_benchmark['s'].iloc[0], 3))        
        
    evaluation_file = "evaluation/blast.tsv"
    evaluation = pd.read_csv(evaluation_file, header=0)
    total_match_list.append(int(evaluation["total_match_count"].iloc[0]))

    data = {'build time (sec)':build_time_list,
            'search time (sec)':search_time_list,
            'match_count':total_match_list}
    
    dfs.append(pd.DataFrame(data))
    
# find mean of each time and missed cell over all repetitions
rep_mean = pd.concat(dfs).groupby(level=0).mean()
rep_mean = rep_mean.round(3)
rep_mean = rep_mean.astype({"match_count" : 'int64'})
rep_mean.to_csv(table, sep='\t')
