lastz_log = "../" + prefix + "/lastz.time"
f = open(lastz_log, "a")
f.write("time\tmem\terror-code\tcommand\tthreads\tseed\tgap-flag\ttransition-flag\tmatches\n")
f.close()

rule lastz_search:
	input:
		ref = dir_path(config["ref"]) + "dna4.fasta",
		query = dir_path(config["query"]) + "dna4.fasta"
	output:
		run_id + "_s{s}_" + gap_flag + "_" + transition_flag + ".maf"
	threads: workflow.cores
	params:
		flags = "--" + gap_flag + " --" + transition_flag 
	shell:
		"""
		/usr/bin/time -a -o {lastz_log} -f "%e\t%M\t%x\t%C\t1\t{wildcards.s}\t{gap_flag}\t{transition_flag}" lastz_32 {input.ref}[multiple] {input.query} {params.flags} \
				--seed={wildcards.s} --progress=1 --format=maf > {output}

		truncate -s -1 {lastz_log}
		grep -v [#] {output} | wc -l | awk '{{print "\t" $1}}' >> {lastz_log}
		"""
