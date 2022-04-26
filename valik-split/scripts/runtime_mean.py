#--------- INPUT ---------
n = snakemake.config["repeat"]
error_rates = [0, 0.025, 0.05, 0.075, 0.1]

#--------- OUTPUT ---------
outfile = snakemake.output[0]

import os
import pandas as pd


def gather_rep_benchmarks(method, rep, prefixes):
    dir_path = "benchmarks/rep" + str(rep) + "/" + method
    total_runtimes = []
    prefix_tuple = tuple(prefixes)
    # summation of run-times from a single repetition
    for er in error_rates:
        rep_er_runtimes = []
        with os.scandir(dir_path) as it:
            for entry in it:
                if (entry.name.endswith("e" + str(er) + ".txt") or entry.name.endswith(prefix_tuple)) and entry.is_file():
                    benchmark = pd.read_csv(entry.path, sep="\t")
                    rep_er_runtimes.append(benchmark["s"].iloc[0])
        it.close()
        total_runtimes.append(sum(rep_er_runtimes))
    return total_runtimes

valik_tuple = ("valik", ["split_ref.txt", "build.txt"])
dream_stellar_tuple = ("dream_stellar", ["files.txt"])
stellar_tuple = ("stellar", [])

tuple_list = [valik_tuple, dream_stellar_tuple, stellar_tuple]

data = {'error_rate' : error_rates}
df = pd.DataFrame(data)

for method in tuple_list:
    for rep in list(range(n)):
        runtimes = gather_rep_benchmarks(method[0], rep, method[1])
        df["rep" + str(rep)] = runtimes

    col = df.loc[: , "rep0":"rep" + str(n - 1)]
    df[method[0]] = col.mean(axis=1).round(2)
    df = df[df.columns.drop(list(df.filter(regex='rep')))]

df["total_dream_stellar"] = df["valik"] + df["dream_stellar"]
df["total_dream_stellar"] = df["total_dream_stellar"].round(2)

df.to_csv(outfile, sep='\t')

