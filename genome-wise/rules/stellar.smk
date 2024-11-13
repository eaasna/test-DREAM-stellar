stellar_log = "../stellar/stellar.time"
f = open(stellar_log, "a")
f.write("time\tmem\terror-code\tcommand\tmin-len\terror-rate\trepeat-period\trepeat-length\tmatches\n")
f.close()

rule stellar:
	input:
		ref = config["ref"],
		query = config["query"]
	output: 
		"../stellar/" + run_id + "_l{min_len}_e{er}_rp{rp}_rl{rl}.gff"
	threads: 1
	shell:
		"""
		(timeout 24h /usr/bin/time -a -o {stellar_log} -f "%e\t%M\t%x\tstellar-search\t{wildcards.min_len}\t{wildcards.er}\t{wildcards.rp}\t{wildcards.rl}" \
			{stellar} -a dna --numMatches {num_matches} \
				--sortThresh {sort_thresh} {input.ref} {input.query} -e {wildcards.er} \
				-l {wildcards.min_len} --repeatPeriod {wildcards.rp} \
				--repeatLength {wildcards.rl} -o {output} || touch {output})

		truncate -s -1 {stellar_log}
		wc -l {output} | awk '{{print "\t" $1}}' >> {stellar_log}
		"""
