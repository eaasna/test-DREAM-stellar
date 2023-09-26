#--------- INPUT ---------
n = snakemake.config["repeat"]
error_rates = [0, 0.025, 0.05, 0.075, 0.1]

#--------- OUTPUT ---------
outfile = snakemake.output[0]

import os
import pandas as pd

# gather benchmarks for steps that are shared between all error rates
def gather_benchmarks(tool, rep, prefixes):
    dir_path = "benchmarks/rep" + str(rep) + "/" + tool
    total_runtimes = []
    prefix_tuple = tuple(prefixes)
    with os.scandir(dir_path) as it:
        for entry in it:
            if (entry.name.endswith(prefix_tuple)) and entry.is_file():
                #print(entry.name)
                benchmark = pd.read_csv(entry.path, sep="\t")
                rep_runtime = benchmark["s"].iloc[0]
                continue
    it.close()
    return rep_runtime

# steps that are repeated for each error rate
def gather_er_benchmarks(tool, rep, prefixes):
    dir_path = "benchmarks/rep" + str(rep) + "/" + tool
    total_runtimes = []
    prefix_tuple = tuple(prefixes)
    # summation of run-times from a single repetition
    for er in error_rates:
        rep_er_runtimes = []
        with os.scandir(dir_path) as it:
            for entry in it:
                if (entry.name.endswith(prefix_tuple) or entry.name.endswith("e" + str(er) + ".txt")) and entry.is_file():
                    #print(entry.name)
                    benchmark = pd.read_csv(entry.path, sep="\t")
                    rep_er_runtimes.append(benchmark["s"].iloc[0])
        it.close()
        total_runtimes.append(sum(rep_er_runtimes))
    return total_runtimes

valik_split_tuple = ("valik", ["split_ref.txt"], "Valik-split")
valik_build_tuple = ("valik", ["build.txt"], "Valik-build")

shared_tuple_list = [valik_split_tuple, valik_build_tuple]

valik_search_tuple = ("valik", [], "Valik-search")
distributed_stellar_tuple = ("dream_stellar", ["files.txt"], "Distributed-Stellar")
stellar_tuple = ("stellar", [], "Stellar")

with_errors_tuple_list = [valik_search_tuple, distributed_stellar_tuple, stellar_tuple]

data = {'Error-rate' : error_rates}
df = pd.DataFrame(data)

for method in shared_tuple_list:
    for rep in list(range(n)):
        runtime = gather_benchmarks(method[0], rep, method[1])
        df["rep" + str(rep)] = runtime
    
    col = df.loc[: , "rep0":"rep" + str(n - 1)]
    df[method[2]] = col.mean(axis=1).round(2)
    df = df[df.columns.drop(list(df.filter(regex='rep')))]

for method in with_errors_tuple_list:
    for rep in list(range(n)):
        runtimes = gather_er_benchmarks(method[0], rep, method[1])
        df["rep" + str(rep)] = runtimes
    
    col = df.loc[: , "rep0":"rep" + str(n - 1)]
    df[method[2]] = col.mean(axis=1).round(2)
    df = df[df.columns.drop(list(df.filter(regex='rep')))]

    
df["DREAM-Stellar"] = df["Valik-split"] + df["Valik-build"] + df["Valik-search"] + df["Distributed-Stellar"]
df["DREAM-Stellar"] = df["DREAM-Stellar"].round(2)

# reorder columns
cols = df.columns.tolist()
cols = cols[:-2] + [cols[-1]] + [cols[-2]]
df = df[cols]
df.to_csv(outfile, sep='\t')
