last_log = "../" + prefix + "/last.time"
f = open(last_log, "a")
f.write("time\tmem\terror-code\tcommand\tthreads\tindex-every\tquery-every\tword-size\tseeding\tmatches\n")
f.close()

def db_name(wildcards):
	return run_id + "_w" + wildcards.w

# https://gitlab.com/mcfrith/last/-/blob/main/doc/last-tuning.rst
# -c: prevents lastal using huge amounts of memory and time on many ways of aligning centromeric repeats.
# -P: parallel threads
# -w: index every nth position in the reference 
#	this increases speed the most while reducing sensitivity the least
#	MegaBLAST indexes every 5th position
rule last_index:
	input:
		dir_path(config["ref"]) + "dna4.fasta"
	output:
		run_id + "_w{w}.suf"
	threads: workflow.cores
	params:
		db = db_name
	shell:
		"""
		( /usr/bin/time -a -o {last_log} -f "%e\t%M\t%x\t%C\t{threads}\t{wildcards.w}\t" \
			lastdb {params.db} -c -P{threads} -w{wildcards.w} {input} 2> last_index.err )
		"""

# https://gitlab.com/mcfrith/last/-/blob/main/doc/last-seeds.rst
# -k: match every nth position in the query
#	this decreases memory and disk use the most while reducing sensitivity the least.
# -l: minimum length of initial exact seeds
# -u: seeding scheme?? not recongnized
#	YASS: DNA default suited for long and weak similarities
#	RY16: reduce run time and memory use by only seeking seeds at 1/16 of positions
rule last_search:
	input:
		ref = dir_path(config["ref"]) + "dna4.fasta",
		db = run_id + "_w{w}.suf",
		query = dir_path(config["query"]) + "dna4.fasta"
	output:
		run_id + "_w{w}_k{k}_l{l}.maf"
	threads: workflow.cores
	params:
		db = db_name
	shell:
		"""
		/usr/bin/time -a -o {last_log} -f "%e\t%M\t%x\t%C\t{threads}\t{wildcards.w}\t{wildcards.k}\t{wildcards.l}" \
			lastal -P{threads} -k{wildcards.k} -l{wildcards.l} {params.db} > {output}

		truncate -s -1 {last_log}
		grep -v [#] {output} | wc -l | awk '{{print "\t" $1}}' >> {last_log}
		"""
		
