import pandas as pd
import numpy as np

# ------- INPUT --------
ref_sizes = ["1Mb", "10Mb"]

# ------- OUTPUT ------- 
table2 = "table2.tsv"

avg_times = []
time_deviations = []
missed = []

for size in ref_sizes:
    print("Processing ref size: " + size)
    table_name = size + "/table1.tsv"
    table = pd.read_csv(table_name, sep='\t', index_col=0)
    time_array = table["time (sec)"]
    avg_times.append(round(np.mean(time_array), 2))
    time_deviations.append(round(np.std(time_array), 3))
    missed.append(np.mean(table["missed (%)"]))
    
data = {'ref_size': ref_sizes,
        'time_mean (sec)': avg_times,
        'time_std_dev': time_deviations,
        'missed (%)': missed}
 
# Create DataFrame
size_mean = pd.DataFrame(data)

size_mean.to_csv(table2, sep='\t')
