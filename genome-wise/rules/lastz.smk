lastz_log = lastz_out + "/lastz.time"
f = open(lastz_log, "a")
f.write("time\tmem\terror-code\tcommand\tthreads\tseed\tgap-flag\ttransition-flag\tstep\tmatches\n")
f.close()

rule lastz_search:
	input:
		ref = ancient(dir_path(config["ref"]) + "dna4.fasta"),
		query = ancient(dir_path(config["query"]) + "dna4.fasta")
	output:
		lastz_out + "/" + run_id + "_s{s}_" + gap_flag + "_" + transition_flag + "_" + str(step_length) + ".maf"
	threads: workflow.cores
	params:
		flags = "--" + gap_flag + " --" + transition_flag 
	shell:
		"""
		/usr/bin/time -a -o {lastz_log} -f "%e\t%M\t%x\t%C\t1\t{wildcards.s}\t{gap_flag}\t{transition_flag}\t{step_length}" lastz_32 {input.ref}[multiple] {input.query} {params.flags} \
				--seed={wildcards.s} --step={step_length} --progress=1 --format=maf > {output}

		truncate -s -1 {lastz_log}
		grep ^s {output} | wc -l | awk '{{print "\t" $1 / 2}}' >> {lastz_log}
		"""

rule lastz_postprocess:
	input:
		lastz_out + "/" + run_id + "_s{s}_" + gap_flag + "_" + transition_flag + "_" + str(step_length) + ".maf"
	output:
		lastz_out + "/" + run_id + "_s{s}_" + gap_flag + "_" + transition_flag + "_" + str(step_length) + ".gff"
	threads: 1
	params:
		tmp_file = "s{s}.tmp"
	shell:
		"""
		grep ^[as] {input} | paste - - - | sed 's/score=//g' | awk '{{print $4 "\tLASTZ\tmatches\t" $5 "\t" $5+$6 "\t100\t" $7 "\t.\t" $11 ";seq2Range=" $12 "," $12+$13 ";eValue=" $2 ";cigar=;mutations=" }}' > {output}		
		"""

