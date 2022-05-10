rule make_parallel_command_list:
	input:
		bins = expand("/dev/shm/seg/seg_{bin}.fasta", bin = bin_list),
		bin_queries = expand("/dev/shm/queries/bin_{bin}_e{er}.fasta", bin = bin_list, er = er_rate)
	output:
		"run_dream_stellar.txt"
	shell:
		"../scripts/make_parallel_list.sh {bins} > {output}"
		
rule dream_stellar_search:
	input:
		"run_dream_stellar.txt"
	output:
		"dream_done"
	params:
		e = 0.025
	threads: 8
	shell:
		"""
		mkdir -p dream_stellar
		( /usr/bin/time -a -o dream_parallel.time -f "%e\t%M\t%x\t%C" parallel --jobs {threads} < run_dream_stellar.txt ) 2> parallel.err
		touch {output}
		"""
	
