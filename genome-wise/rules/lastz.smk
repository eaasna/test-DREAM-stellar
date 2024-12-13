lastz_log = "../" + prefix + "/lastz.time"
f = open(lastz_log, "a")
f.write("time\tmem\terror-code\tcommand\tchr\tthreads\tseed\tgap-flag\ttransition-flag\tmatches\n")
f.close()

def db_name(wildcards):
	return run_id + "_w" + wildcards.w

rule chr_ids:
	input:
		config["query"]
	output:
		config["query"] + ".ids"
	threads: 1
	shell:
		"""
		grep ">" {input} | sed 's/>//g' | awk '{{print $1}}' > {output}
		"""

def id_list():
	query_ids = []
	with open(config["query"] + ".ids") as f:
    		query_ids = f.read().splitlines()
	return query_ids

import math
def files_per_chunk():
	query_ids = id_list()
	n = math.ceil(len(query_ids) / workflow.cores)
	print("Process " + str(n) + " files per thread")
	return n

rule lastz_split_chunks:
	input:
		query = config["query"],
		ids = config["query"] + ".ids"
	output:
		temp(expand("{chunk_id}.fasta", chunk_id = list(range(workflow.cores))))
	threads: 1
	params:
		m = files_per_chunk()
	shell:
		"""
		chunk=0
		file_counter=0
		while read id;
		do
			grep -A 1 -w ">$id" {input.query} >> $chunk.fasta
			file_counter=$file_counter+1
			if [[ $file_counter -eq {params.m} ]]
			then
				file_counter=0
				chunk=$((chunk+1))
			fi
		done < {input.ids}
		"""

rule lastz_search:
	input:
		ref = config["ref"],
		query = "{chunk_id}.fasta"
	output:
		"{chunk_id}_s{s}_" + gap_flag + "_" + transition_flag + ".maf"
	threads: workflow.cores
	params:
		flags = "--" + gap_flag + " --" + transition_flag 
	shell:
		"""
		/usr/bin/time -a -o {lastz_log} -f "%e\t%M\t%x\t%C\t1\t{wildcards.chunk_id}\t{wildcards.s}\t{gap_flag}\t{transition_flag}" lastz_32 {input.ref}[multiple] {input.query} {params.flags} \
				--seed={wildcards.s} --progress=1 --format=maf > {output}

		truncate -s -1 {lastz_log}
		grep -v [#] {output} | wc -l | awk '{{print "\t" $1}}' >> {lastz_log}
		"""
		
rule gather_lastz:
	input:
		expand("{chunk_id}_s{{s}}_" + gap_flag + "_" + transition_flag + ".maf", chunk_id = list(range(workflow.cores)))
	output:
		run_id + "_s{s}_" + gap_flag + "_" + transition_flag + ".maf"
	shell:
		"cat {input} > {output}"
