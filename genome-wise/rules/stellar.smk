stellar_log = "stellar.time"
f = open(stellar_log, "a")
f.write("time\tmem\terror-code\tcommand\tmin-len\terror-rate\trepeat-period\trepeat-length\tmatches\n")
f.close()

def get_error_rate(wildcards):
	return int(wildcards.er) / int(wildcards.min_len)
rule stellar:
	input:
		ref = dir_path(config["ref"]) + "dna4.fasta",
		query = dir_path(config["query"]) + "dna4.fasta"
	output: 
		stellar_out + "/" + run_id + "_l{min_len}_e{er}_rp{rp}_rl{rl}.gff"
	threads: 1
	params: 
		er_rate = get_error_rate
	shell:
		"""
		(timeout 24h /usr/bin/time -a -o {stellar_log} -f "%e\t%M\t%x\tstellar-search\t{wildcards.min_len}\t{params.er_rate}\t{wildcards.rp}\t{wildcards.rl}" \
			{stellar} -a dna --numMatches {num_matches} \
				--sortThresh {sort_thresh} {input.ref} {input.query} -e {params.er_rate} \
				-l {wildcards.min_len} --repeatPeriod {wildcards.rp} \
				--repeatLength {wildcards.rl} -o {output} 2> {output}.err || touch {output})

		truncate -s -1 {stellar_log}
		wc -l {output} | awk '{{print "\t" $1}}' >> {stellar_log}
		"""
