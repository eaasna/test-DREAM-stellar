#---------- INPUT ----------
sim_er = 8
search_er = 2
o = 49

bins = 64
bin_list = list(range(bins))
bin_list = [str(bin).zfill(len(str(bins))) for bin in bin_list]

import pandas as pd
import numpy as np

# input: path to stellar output
# output: df where instead of specific sequences reads are mapped to a bin
def get_stellar_bin_df(stellar_path):
    stellar_bin_df = pd.read_csv(stellar_path, sep=" ", header=None)
    stellar_bin_df.columns = ["Stellar-BIN", "QID"]
    stellar_bin_df["Stellar-BIN"] = pd.to_numeric(stellar_bin_df["Stellar-BIN"].str.split("_").str[1])
    stellar_bin_df = stellar_bin_df[["QID", "Stellar-BIN"]].drop_duplicates()
    return stellar_bin_df

def get_stellar_df():
    frames = []
    for b in bin_list:
        stellar_path = stellar_path = "matches/bin_" + b + "_e" + str(sim_er) + ".txt"
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
def size_search_accuracy():
    stellar_df = get_stellar_df()
    with open('search_accuracy.tsv', 'a') as f:
        f.write("IBF-size\tTP\tFP\tFN\tPrecision\tRecall\n")
        for size in size_list:
            valik_path = size + "/e" + str(sim_er) + "_o" + str(o) + ".out"
            valik_df = get_valik_df(valik_path)

            TP_df = pd.merge(valik_df, stellar_df,  how='inner', left_on=["QID","Valik-BIN"], right_on = ["QID","Stellar-BIN"])
            TP = len(TP_df["QID"])

            # number of unnecessary bins that need to be searched
            FP = len(valik_df["QID"]) - TP

            # number of bin matches that can not be found after prefiltering
            FN = len(stellar_df["QID"]) - TP

            precision = TP / (TP + FP)

            recall = TP / (TP + FN)

            f.write(size + "\t" + str(TP) + "\t" + str(FP) + "\t" + str(FN) + "\t" + str(precision)
                    + "\t" + str(recall) + "\n")

            print("Finished processing {}".format(size))
    f.close()

size_list = ["1M", "5M", "10M", "15M", "20M", "25M", "30M", "35M", "40M", "45M", "50M", "55M", "60M"]

size_search_accuracy()
