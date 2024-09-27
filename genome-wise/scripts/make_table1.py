import pandas as pd

# ------- INPUT --------
#n = 1
n = snakemake.params.repeats

prefix = snakemake.params.prefix
#prefix = "valik"

# ------- OUTPUT ------- 
table = snakemake.output[0]
#table = prefix + "_table1_test.tsv"

error_rate_list = snakemake.params.error_rates
#error_rate_list = [0.05]


dfs = []
for rep in range(n):
    search_time_list = []
    build_time_list = []
    #missed_list = []
    total_match_list = []
    for er in error_rate_list:
        if (prefix == "valik"):
            search_benchmark_file = "benchmarks/valik_e" + str(er) + "_b" + str(snakemake.wildcards.b) + ".txt"
            build_benchmark_file = "benchmarks/valik_build_b" + str(snakemake.wildcards.b) + ".txt"
            build_benchmark = pd.read_csv(build_benchmark_file, sep='\t')
            build_time_list.append(round(build_benchmark['s'].iloc[0], 3))        
            evaluation_file = "evaluation/valik_e" + str(er) + "_b" + str(snakemake.wildcards.b) + ".tsv"
        elif (prefix == "stellar"):
            search_benchmark_file = "benchmarks/stellar_e" + str(er) + ".txt"
            evaluation_file = "evaluation/stellar_e" + str(er) + ".tsv"
        else:
            print("Unknwon prefix: " + prefix)

        search_benchmark = pd.read_csv(search_benchmark_file, sep='\t')
        search_time_list.append(round(search_benchmark['s'].iloc[0], 3))

        evaluation = pd.read_csv(evaluation_file, header=0)
        total_match_list.append(int(evaluation["total_match_count"].iloc[0]))


    data = {'error_rate':error_rate_list,
            'search time (sec)':search_time_list,
            #'missed (%)':missed_list}
            'match_count':total_match_list}

    if (prefix == "valik"):
        data.insert(1, 'build time (sec)', build_time_list)
    
    dfs.append(pd.DataFrame(data))
    
# find mean of each time and missed cell over all repetitions
rep_mean = pd.concat(dfs).groupby(level=0).mean()
rep_mean = rep_mean.round(3)
rep_mean = rep_mean.as_type({"total_match_count" : 'int64'})
rep_mean.to_csv(table, sep='\t')
