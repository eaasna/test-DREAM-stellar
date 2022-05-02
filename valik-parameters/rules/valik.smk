import math
def get_error_count(wildcards):
	if (wildcards.er == "0"):
		e = 0
	e = int(math.floor(float(wildcards.er) * pattern))
	return e

rule valik_build:
	input:
		fasta = expand("bins/bin_{bin}.fasta", bin = bin_list),
		meta = "bin_paths.txt"
	output: 
		ibf = temp("{size}/valik.index")
	threads: 16
	shell:
		"valik build {input.meta} --threads {threads} --window {w} --kmer {k} --output {output.ibf} --size {wildcards.size}"

rule valik_search:
	input:
		ibf = "{size}/valik.index",
		query = "queries/e{er}.fastq"
	output:
		"{size}/e{er}_o{o}.out"
	threads: 16
	params:
		e = get_error_count
	shell:
		"valik search --index {input.ibf} --query {input.query} --error {params.e} --pattern {pattern} --overlap {wildcards.o} --threads {threads} --output {output}"	

