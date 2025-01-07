lastz_log = lastz_out + "/lastz.time"
f = open(lastz_log, "a")
f.write("time\tmem\terror-code\tcommand\tthreads\tseed\tgap-flag\ttransition-flag\tmatches\n")
f.close()

rule lastz_search:
	input:
		ref = ancient(dir_path(config["ref"]) + "dna4.fasta"),
		query = ancient(dir_path(config["query"]) + "dna4.fasta")
	output:
		lastz_out + "/" + run_id + "_s{s}_" + gap_flag + "_" + transition_flag + ".maf"
	threads: workflow.cores
	params:
		flags = "--" + gap_flag + " --" + transition_flag 
	shell:
		"""
		/usr/bin/time -a -o {lastz_log} -f "%e\t%M\t%x\t%C\t1\t{wildcards.s}\t{gap_flag}\t{transition_flag}" lastz_32 {input.ref}[multiple] {input.query} {params.flags} \
				--seed={wildcards.s} --progress=1 --format=maf > {output}

		truncate -s -1 {lastz_log}
		grep ^s {output} | wc -l | awk '{{print "\t" $1 / 2}}' >> {lastz_log}
		"""

rule lastz_postprocess:
	input:
		lastz_out + "/" + run_id + "_s{s}_" + gap_flag + "_" + transition_flag + ".maf"
	output:
		lastz_out + "/" + run_id + "_s{s}_" + gap_flag + "_" + transition_flag + ".gff"
	threads: 1
	params:
		tmp_file = "s{s}.tmp"
	shell:
		"""
		grep ^s {input} | awk '{{ print $2 "\t" $3 "\t" $4 "\t" $5 }}' > {params.tmp_file}
		paste - - < {params.tmp_file} | awk '{{ print $1 "\tLASTZ\tmatches\t" $2 "\t" $2+$3 "\t" 100 "\t" $4 "\t.\t" $5 ";seq2Range=" $6 "," $6+$7 ";cigar=;mutations=" }}' > {output}
		rm {params.tmp_file}
		"""

