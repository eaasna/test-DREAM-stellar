last_log = last_out + "/last.time"
f = open(last_log, "a")
f.write("time\tmem\terror-code\tcommand\tthreads\tindex-every\tquery-every\tword-size\tmatches\n")
f.close()

#def db_name(wildcards):
#	return run_id + "_w" + wildcards.w

def db_name(wildcards):
	return last_out + "/" + run_id

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
		last_out + "/" + run_id + "_w{last_w}.suf"
	threads: workflow.cores
	params:
		db = db_name
	shell:
		"""
		( /usr/bin/time -a -o {last_log} -f "%e\t%M\t%x\t%C\t{threads}\t{wildcards.last_w}" \
			lastdb {params.db} -c -P{threads} {input} 2> last_index.err )
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
		db = last_out + "/" + run_id + ".suf",
		query = dir_path(config["query"]) + "dna4.fasta"
	output:
		last_out + "/" + run_id + "_w{last_w}_k{last_k}_l{last_l}.tsv"
	threads: workflow.cores
	params:
		db = db_name
	shell:
		"""
		(timeout 24h /usr/bin/time -a -o {last_log} -f "%e\t%M\t%x\t%C\t{threads}\t{wildcards.last_w}\t{wildcards.last_k}\t{wildcards.last_l}" \
			lastal -P{threads} {params.db} {input.query} \
				-l {wildcards.last_l} -k {wildcards.last_k} \
				-f BlastTab > {output})

		truncate -s -1 {last_log}
		grep -v [#] {output} | wc -l | awk '{{print "\t" $1}}' >> {last_log}
		"""

# BLAST reverse strand matches dstart > dend
# LAST reverse strand matches qstart > qend
# Stellar reverse strand matches (dstart < dend) & (qstart < qend)
rule last_convert_to_blast:
	input:
		last_out + "/" + run_id + "_w{last_w}_k{last_k}_l{last_l}.tsv"
	output:
		last_out + "/" + run_id + "_w{last_w}_k{last_k}_l{last_l}.bed"
	threads: 1
	shell:
		"""
		grep -v "#" {input} | \
			awk '{ if($7>$8) $5="minus"; else $5="plus"; print $1 "\t" $9 "\t" $10 "\t" $3 "\t" $5 "\t" $11 "\t" $2 "\t" $7 "\t" $8 ; }' | \
			awk '$8>$9{tmp=$8; $8=$9; $9=$8} 1' | \
			awk '$5=="minus"{tmp=$2; $2=$3; $3=tmp} 1' > {output}
		"""

