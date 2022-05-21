rule make_parallel_command_list:
	input:
		ref_seg = expand("{{b}}/bins/bin_{bin}.fasta", bin = bin_list),
		query = expand("/dev/shm/{{b}}/queries/bin_{bin}_e{er}.fasta", bin = bin_list, er = er_rate)
	output:
		"{b}/run_dream_stellar.txt"
	threads: 1
	shell:
		"../scripts/make_parallel_list.sh {wildcards.b} > {output}"
		
rule dream_stellar_search:
	input:
		"{b}/run_dream_stellar.txt"
	output:
		"dream_{b}_done"
	params:
		e = 0.025
	threads: 16
	shell:
		"""
		( /usr/bin/time -a -o dream_{wildcards.b}_parallel.time -f "%e\t%M\t%x\t%C" parallel --jobs {threads} < {wildcards.b}/run_dream_stellar.txt ) 2> parallel.err
		touch dream_{wildcards.b}_done
		"""
	
