stellar_log = "stellar.time"
f = open(stellar_log, "a")
f.write("time\tmem\texit-code\tcommand\tthreads\terror-rate\tmatches\n")
f.close()

rule stellar:
	input:
		ref = "ref_rep{rep}.fasta",
		query = "query/rep{rep}_e{er}.fasta"
	output: 
		"stellar/rep{rep}_e{er}.gff"
	threads: workflow.cores
	benchmark:
		"benchmarks/stellar_rep{rep}_e{er}.txt"
	shell:
		"""
		( timeout 12h /usr/bin/time -a -o {stellar_log} -f "%e\t%M\t%x\tstellar-search\t1\t{wildcards.er}" stellar --time -a dna --numMatches {num_matches}  --sortThresh {sort_thresh} {input.ref} {input.query} -e {wildcards.er} -l {min_len} -o {output} 2> {output}.err || touch {output} )
		
		truncate -s -1 {stellar_log}
		wc -l {output} | awk '{{ print $1 }}' >> {stellar_log}
		"""
