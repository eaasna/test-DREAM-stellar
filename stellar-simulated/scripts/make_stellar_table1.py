import pandas as pd

# ------- INPUT ------- 
benchmark_file = snakemake.input.benchmark

# ------- INPUT ------- 
table = snakemake.output[0]

benchmark = pd.read_csv(benchmark_file, sep='\t')

error_rate_list = benchmark['error_rate'].tolist()
time_list = benchmark['sec'].tolist()
missed_list = []

for er_int in error_rate_list:
    er_str = str(er_int).rstrip("0").replace(".", "")
    evaluation_file = "evaluation/" + er_str + ".tsv"
    evaluation = pd.read_csv(evaluation_file, sep='\t', index_col = 0)
    missed_list.append(round(evaluation["missed"].iloc[0], 3))

data = {'error_rate':error_rate_list,
        'time (sec)':time_list,
        'missed (%)':missed_list}
 
df = pd.DataFrame(data)
df.to_csv(table, sep='\t')
