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

rule valik_build:
	input:
		ref = "rep{rep}/ref.fasta",
		ref_meta = "rep{rep}/split/ref.txt",
		seg_meta = "rep{rep}/split/seg.txt"
	output: 
		"rep{rep}/valik.index"
	benchmark:
		"benchmarks/rep{rep}/valik/build.txt"
	shell:
		"valik build --from-segments {input.ref} --threads {threads} --window {w} --kmer {k} --output {output} --size {size} --seg-path {input.seg_meta} --ref-meta {input.ref_meta}"

rule valik_search:
	input:
		ibf = "rep{rep}/valik.index",
		query = "rep{rep}/queries/e{er}.fastq"
	output:
		"rep{rep}/search/e{er}.out"
	threads: 8
	params:
		e = get_error_count
	benchmark:
		"benchmarks/rep{rep}/valik/search_e{er}.txt"
	shell:
		"valik search --index {input.ibf} --query {input.query} --error {params.e} --pattern {pattern} --overlap {overlap} --output {output} --tau {tau} --p_max {pmax}"
		
