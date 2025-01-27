lastz_log = lastz_out + "/lastz.time"
f = open(lastz_log, "a")
f.write("time\tmem\terror-code\tcommand\tthreads\tseed\tgap-flag\ttransition-flag\tstep\tmatches\n")
f.close()

rule lastz_search:
	input:
		ref = ancient(dir_path(config["ref"]) + "dna4.fasta"),
		query = ancient(dir_path(config["query"]) + "dna4.fasta")
	output:
		lastz_out + "/" + run_id + "_s{s}_" + gap_flag + "_" + transition_flag + "_" + str(step_length) + ".tsv"
	threads: workflow.cores
	params:
		flags = "--" + gap_flag + " --" + transition_flag 
	shell:
		"""
		(timeout 24h /usr/bin/time -a -o {lastz_log} -f "%e\t%M\t%x\t%C\t1\t{wildcards.s}\t{gap_flag}\t{transition_flag}\t{step_length}" lastz_32 {input.ref}[multiple] {input.query} {params.flags} --hspthresh={hsp} \
				--seed={wildcards.s} --step={step_length} --progress=1 --format=blastn > {output})

		truncate -s -1 {lastz_log}
		grep ^s {output} | wc -l | awk '{{print "\t" $1 / 2}}' >> {lastz_log}
		"""

rule lastz_convert_to_blast:
	input:
		lastz_out + "/" + run_id + "_s{s}_" + gap_flag + "_" + transition_flag + "_" + str(step_length) + ".tsv"
	output:
		lastz_out + "/" + run_id + "_s{s}_" + gap_flag + "_" + transition_flag + "_" + str(step_length) + ".bed"
	threads: 1
	shell:
		"""
		grep -v "#" {input} | \
			awk '{ if($7>$8) $5="minus"; else $5="plus"; print $1 "\t" $9 "\t" $10 "\t" $3 "\t" $5 "\t" $11 "\t" $2 "\t" $7 "\t" $8 ; }' | \
			awk '$8>$9{tmp=$8; $8=$9; $9=$8} 1' | \
			awk '$5=="minus"{tmp=$2; $2=$3; $3=tmp} 1' > {output}
		"""

