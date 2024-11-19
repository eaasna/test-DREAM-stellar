f = open("search_valik.time", "a")
f.write("time\tmem\terror-code\tcommand\tbins\tfpr\tmax-er\tmin-len\tthreads\terror-rate\trepeat-period\trepeat-length\tmatches\n")
f.close()

rule distributed_stellar:
	input:
		query = config["query"],
		ref_meta = "meta/b{b}_fpr{fpr}_l{min_len}_e{er}.bin"
	output:
		"b{b}_fpr{fpr}_l{min_len}_e{er}_t{t}_rp{rp}_rl{rl}.gff"
	threads: workflow.cores
	params:
		log = "search_valik.time"
	shell:
		"""
		(/usr/bin/time -a -o {params.log} -f \
			"%e\t%M\t%x\tvalik-search\t{wildcards.b}\t{wildcards.fpr}\t{wildcards.er}\t{wildcards.min_len}\t{threads}\t{wildcards.er}\t{wildcards.rp}\t{wildcards.rl}" \
			{valik} search --verbose --stellar-only \
				--split-query --numMatches {num_matches} \
				--sortThresh {sort_thresh} --time --ref-meta {input.ref_meta} \
				--query {input.query} --error-rate {wildcards.er} --threads {wildcards.t} \
				--repeatPeriod {wildcards.rp} --repeatLength {wildcards.rl} \
				--output {output} &> {output}.stellar.err)

		truncate -s -1 {params.log}
		wc -l {output} | awk '{{ print "\t" $1}}' >> {params.log}
		"""

