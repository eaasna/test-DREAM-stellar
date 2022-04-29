import math
def get_error_count(wildcards):
	if (wildcards.er == "0"):
		e = 0
	e = int(math.floor(float(wildcards.er) * pattern))
	return e

rule valik_build:
	input:
		fasta = expand("rep{{rep}}/bins/bin_{bin}.fasta", bin = bin_list),
		meta = "rep{rep}/bin_paths.txt"
	output: 
		ibf = temp("/dev/shm/rep{rep}/valik.index")
	threads: 16
	benchmark:
		"benchmarks/rep{rep}/valik/build.txt"
	shell:
		"valik build {input.meta} --threads {threads} --window {w} --kmer {k} --output {output.ibf} --size {size}"

rule valik_search:
	input:
		ibf = "/dev/shm/rep{rep}/valik.index",
		query = "rep{rep}/queries/e{er}.fastq"
	output:
		"rep{rep}/search/e{er}.out"
	threads: 16
	params:
		e = get_error_count
	benchmark:
		"benchmarks/rep{rep}/valik/search_e{er}.txt"
	shell:
		"valik search --index {input.ibf} --query {input.query} --error {params.e} --pattern {pattern} --overlap {overlap} --threads {threads} --output {output} --tau {tau} --p_max {pmax}"
		
