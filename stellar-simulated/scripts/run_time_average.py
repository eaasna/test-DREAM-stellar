import pandas as pd
import time

avg_out_file = snakemake.output.avg

error_rates = ["0", "0025", "005", "0075", "01"]
float_error_rates = [float(er[:1] + '.' + er[1:]) for er in error_rates]

mean_time_list = []
hhmmss_list = []

for er in error_rates:
    benchmark_file = "benchmarks/stellar_" + er + ".txt" 
    benchmark = pd.read_csv(benchmark_file, sep='\t')
    mean_sec = round(benchmark["s"].mean(), 2)
    
    mean_time_list.append(mean_sec)
    hhmmss_list.append(time.strftime('%H:%M:%S', time.gmtime(mean_sec)))

benchmark_avg = {'error_rate':float_error_rates,
                'sec':mean_time_list,
                'hh:mm:ss':hhmmss_list}

avg_df = pd.DataFrame(benchmark_avg)
avg_df.to_csv(avg_out_file, index=False, sep='\t')

