stellar_log = "stellar.distributed.time"
f = open(stellar_log, "a")
f.write("time\tmem\terror-code\tcommand\tmax-er\tmin-len\tthreads\terror-rate\trepeat-period\trepeat-length\tmatches\n")
f.close()

rule distributed_stellar:
	input:
		query = dir_path(config["query"]) + "dna4.fasta",
		ref_meta = dream_out + "/meta/b" + str(bin_list[0]) + "_fpr" + str(fpr_list[0]) + "_l{min_len}_e{er}.bin"
	output:
		stellar_out + "/" + run_id + "_l{min_len}_e{er}_rp{rp}_rl{rl}.gff"
	threads: workflow.cores
	params:
		er_rate = get_error_rate
	shell:
		"""
		(/usr/bin/time -a -o {stellar_log} -f \
			"%e\t%M\t%x\tdistributed-stellar\t{wildcards.er}\t{wildcards.min_len}\t{threads}\t{wildcards.er}\t{wildcards.rp}\t{wildcards.rl}" \
			{valik} search --verbose --stellar-only \
				--split-query --numMatches {num_matches} \
				--sortThresh {sort_thresh} --time --ref-meta {input.ref_meta} \
				--query {input.query} --error-rate {params.er_rate} --threads {threads} \
				--repeatPeriod {wildcards.rp} --repeatLength {wildcards.rl} \
				--output {output} &> {output}.stellar.err)

		truncate -s -1 {stellar_log}
		wc -l {output} | awk '{{ print "\t" $1}}' >> {stellar_log}
		"""

