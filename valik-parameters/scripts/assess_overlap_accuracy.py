import numpy as np
import pandas as pd

#---------- INPUT ----------
sim_er = 8
search_er = 2
o = 49
size = "10M"

bins = 64
bin_list = list(range(bins))
bin_list = [str(bin).zfill(len(str(bins))) for bin in bin_list]
read_len = 150
pattern_size = 50
workdirs = ["overlap", "overlap_kmers"]
overlap_list = [0, 10, 20, 30, 40, 45, 46, 47, 48, 49]

# input: path to stellar output
# output: df where instead of specific sequences reads are mapped to a bin
def get_stellar_bin_df(stellar_path):
    stellar_bin_df = pd.read_csv(stellar_path, sep=" ", header=None)
    stellar_bin_df.columns = ["Stellar-BIN", "QID"]
    stellar_bin_df["Stellar-BIN"] = pd.to_numeric(stellar_bin_df["Stellar-BIN"].str.split("_").str[1])
    stellar_bin_df = stellar_bin_df[["QID", "Stellar-BIN"]].drop_duplicates()
    return stellar_bin_df

def get_stellar_df(workdir):
    frames = []
    for b in bin_list:
        stellar_path = stellar_path = "../" + workdir + "/matches/bin_" + b + "_e" + str(sim_er) + ".txt"
        stellar_bin_df = get_stellar_bin_df(stellar_path)
        frames.append(stellar_bin_df)

    stellar_df = pd.concat(frames, ignore_index = True)
    stellar_df = stellar_df.drop_duplicates()
    return stellar_df

def get_valik_df(valik_path):
    valik_df = pd.read_csv(valik_path, sep="\t", header=None)
    valik_df.columns = ["QID", "matches"]
    valik_df = valik_df.assign(match_cols=valik_df['matches'].str.split(',')).explode('matches')
    valik_df = valik_df.drop(["matches"], axis = 1)
    valik_df = valik_df.explode("match_cols")
    valik_df.columns = ["QID", "Valik-BIN"]
    valik_df = valik_df.replace(r'^\s*$', np.nan, regex=True).dropna() # drop empty rows
    valik_df = valik_df.reset_index(drop = True)
    valik_df["Valik-BIN"] = pd.to_numeric(valik_df["Valik-BIN"])
    return valik_df

import os.path
for workdir in workdirs:
    stellar_df = get_stellar_df(workdir)

    runtime_list = []
    pattern_count_list = []
    for overlap in overlap_list:
        # find number of patterns
        pattern_begin_positions = []
        for i in range(0, read_len - pattern_size + 1, pattern_size - overlap):
            pattern_begin_positions.append(i)
            last_begin = i

        if (last_begin < read_len - pattern_size):
            # last pattern might have a smaller overlap to make sure the end of the read is covered
            pattern_begin_positions.append(read_len - pattern_size)

        pattern_count_list.append(len(pattern_begin_positions))

        # gather run-time
        time_file = "../" + workdir + "/" + str(overlap) + "_valik.time"
        time = pd.read_csv(time_file, sep="\t", header=None)
        avg_runtime = round(np.mean(time[0]), 2)
        runtime_list.append(avg_runtime)

    with open('../' + workdir + '/search_accuracy.tsv', 'a') as f:
        f.write("overlap\t#patterns\tTP\tFP\tFN\tPrecision\tRecall\tRuntime(sec)\n")
        for i in range(len(overlap_list)):
            overlap = overlap_list[i]
            runtime = runtime_list[i]
            pattern_count = pattern_count_list[i]

            valik_path = "../" + workdir + "/" + size + "/e" + str(sim_er) + "_o" + str(overlap) + ".out"
            valik_df = get_valik_df(valik_path)

            TP_df = pd.merge(valik_df, stellar_df,  how='inner', left_on=["QID","Valik-BIN"], right_on = ["QID","Stellar-BIN"])
            TP = len(TP_df["QID"])

            # number of unnecessary bins that need to be searched
            FP = len(valik_df["QID"]) - TP

            # number of bin matches that can not be found after prefiltering
            FN = len(stellar_df["QID"]) - TP

            precision = TP / (TP + FP)

            recall = TP / (TP + FN)

            f.write(str(overlap) + "\t" + str(pattern_count) + "\t" + str(TP) + "\t" + str(FP) + "\t" + str(FN) + "\t" + str(precision)
                    + "\t" + str(recall) + "\t" + str(runtime) + "\n")

            print("Finished processing {}".format(overlap))
    f.close()
