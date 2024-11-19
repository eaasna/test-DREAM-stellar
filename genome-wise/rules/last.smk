last_log = "../" + prefix + "/last.time"
f = open(last_log, "a")
f.write("time\tmem\terror-code\tcommand\tthreads\tindex-every\tquery-every\tword-size\tseeding\tmatches\n")
f.close()

import os 

def db_name(wildcards):
	return "w" + wildcards.w

def dir_path(filename):
	return os.path.split(filename)[0] + "/"

# https://gitlab.com/mcfrith/last/-/blob/main/doc/last-tuning.rst
# -c: prevents lastal using huge amounts of memory and time on many ways of aligning centromeric repeats.
# -P: parallel threads
# -w: index every nth position in the reference 
#	this increases speed the most while reducing sensitivity the least
#	MegaBLAST indexes every 5th position
rule last_index:
	input:
		config["ref"]
	output:
		dir_path(config["ref"]) + "w{w}.pre"
	threads: workflow.cores
	params:
		db = db_name
	shell:
		"""
		( /usr/bin/time -a -o {last_log} -f "%e\t%M\t%x\t%C\t1\t{wildcards.w}\t" \
			lastdb {params.db} -c -w{wildcards.w} {input})
		"""

# https://gitlab.com/mcfrith/last/-/blob/main/doc/last-seeds.rst
# -k: match every nth position in the query
#	this decreases memory and disk use the most while reducing sensitivity the least.
# -l: minimum length of initial exact seeds
# -u: seeding scheme
#	YASS: DNA default suited for long and weak similarities
#	RY16: reduce run time and memory use by only seeking seeds at 1/16 of positions
rule last_search:
	input:
		ref = config["ref"],
		db = dir_path(config["ref"]) + "w{w}.pre",
		query = config["query"]
	output:
		"../" + prefix + "/" + run_id + "_w{w}_k{k}_l{l}_u{u}.maf"
	threads: workflow.cores
	params:
		db = db_name
	shell:
		"""
		/usr/bin/time -a -o {last_log} -f "%e\t%M\t%x\t%C\t{threads}\t{wildcards.w}\t{wildcards.k}\t{wildcards.l}\t{wildcards.u}" \
			lastal -P{threads} -k {wildcards.k} -l{wildcards.l} \
				-u{wildcards.u} {input.db} > {output}

		truncate -s -1 {last_log}
		wc -l {output} | awk '{{print "\t" $1}}' >> {last_log}
		"""
		
