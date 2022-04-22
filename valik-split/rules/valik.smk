bins = config["ibf_bins"]
w = config["window"]
k = config["kmer_length"]
size = config["ibf_size"]
overlap = config["pattern_overlap"]

pattern = config["minLen"]
tau = config["thresh_tau"]
pmax = config["thresh_pmax"]

import math
def get_error_count(wildcards):
        if (wildcards.er == "0"):
                e = 0
        e = int(math.floor(float(wildcards.er) * pattern))
	print(e)
	return e

rule valik_split_ref:
        input:
                "ref_rep{rep}.fasta"
        output: 
                ref_meta = "split/ref_rep{rep}.txt",
		seg_meta = "split/ref_seg_rep{rep}.txt"
	benchmark:
		"benchmarks/split_ref_rep{rep}.txt"
	shell:
		"valik split {input} --reference-output {output.ref_meta} --segment-output {output.seg_meta} --overlap {max_len} --bins {bins}"

rule valik_build:
	input:
		ref = "ref_rep{rep}.fasta",
		ref_meta = "split/ref_rep{rep}.txt",
		seg_meta = "split/ref_seg_rep{rep}.txt"
	output: 
		"build/rep{rep}.index"
	benchmark:
		"benchmarks/build_rep{rep}.txt"
	shell:
		"valik build --from-segments {input.ref} --threads {threads} --window {w} --kmer {k} --output {output} --size {size} --seg-path {input.seg_meta} --ref-meta {input.ref_meta}"

rule valik_search:
	input:
		ibf = "build/rep{rep}.index",
		query = "queries/rep{rep}_e{er}.fastq"
	output:
		"search/rep{rep}_e{er}.out"
	threads: 8
	params:
		e = get_error_count
	benchmark:
		"benchmarks/search_rep{rep}_er{er}.txt"
	shell:
		"valik search --index {input.ibf} --query {input.query} --error {params.e} --pattern {pattern} --overlap {overlap} --output {output} --tau {tau} --p_max {pmax}"
		


