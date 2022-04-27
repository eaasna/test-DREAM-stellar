import math
def get_error_count(wildcards):
        if (wildcards.er == "0"):
                e = 0
        e = int(math.floor(float(wildcards.er) * pattern))
	print(e)
	return e

rule valik_split_ref:
        input:
                "rep{rep}/ref.fasta"
        output: 
                ref_meta = "rep{rep}/split/ref.txt",
		seg_meta = "rep{rep}/split/seg.txt"
	benchmark:
		"benchmarks/rep{rep}/valik/split_ref.txt"
	shell:
		"valik split {input} --reference-output {output.ref_meta} --segment-output {output.seg_meta} --overlap {max_len} --bins {bins}"

# assuming a single reference sequence
rule create_seg_files:
        input:
                ref = "rep{rep}/ref.fasta",
                seg_meta = "rep{rep}/split/seg.txt"
        output:
                fasta = expand("rep{{rep}}/split/seg{bin}.fasta", bin = bin_list),
		meta = "rep{rep}/split/bin_paths.txt"
        benchmark:
                "benchmarks/rep{rep}/dream_stellar/create_seg_files.txt"
        script:
                "../scripts/create_seg_files.py"

rule valik_build_parallel:
	input:
                fasta = expand("rep{{rep}}/split/seg{bin}.fasta", bin = bin_list),
		meta = "rep{rep}/split/bin_paths.txt"
	output: 
		ibf = "rep{rep}/valik_parallel.index"
	threads: 8
	params:
		lim = bins - 1
	benchmark:
		"benchmarks/rep{rep}/valik/build.txt"
	shell:
		"valik build {input.meta} --threads {threads} --window {w} --kmer {k} --output {output.ibf} --size {size}"

rule valik_search:
	input:
		ibf = "rep{rep}/valik_parallel.index",
		query = "rep{rep}/queries/e{er}.fastq"
	output:
		"rep{rep}/search/e{er}.out"
	threads: 8
	params:
		e = get_error_count
	benchmark:
		"benchmarks/rep{rep}/valik/search_e{er}.txt"
	shell:
		"valik search --index {input.ibf} --query {input.query} --error {params.e} --pattern {pattern} --overlap {overlap} --threads {threads} --output {output} --tau {tau} --p_max {pmax}"
		
