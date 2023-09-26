rule valik_split_ref:
	input:
		"ref_rep{rep}.fasta"
	output: 
		ref_meta = "meta/ref_rep{rep}.txt"
	shell:
		"valik split {input} --out {output.ref_meta} --split-index --overlap {min_len} -n {bins}"

rule valik_split_query:
	input:
		"query/with_insertions_rep{rep}_e{er}.fasta"
	output: 
		query_meta = "meta/query_rep{rep}_e{er}.txt",
	shell:
		"valik split {input} --out {output.query_meta} --overlap {min_len} -n {bins}"

rule valik_build:
	input:
		ref = "ref_rep{rep}.fasta",
		ref_meta = "meta/ref_rep{rep}.txt"
	output: 
		"rep{rep}.index"
	threads: 8
	shell:
		"valik build {input.ref} --threads {threads} --window {w} --kmer {k} --output {output} --size {size} --ref-meta {input.ref_meta}"

rule valik_search:
	input:
		ibf = "rep{rep}.index",
		query = "query/with_insertions_rep{rep}_e{er}.fasta",
		query_meta = "meta/query_rep{rep}_e{er}.txt",
		ref_meta = "meta/ref_rep{rep}.txt"
	output:
		"valik/rep{rep}_e{er}.gff"
	threads: 8
	params:
		e = get_search_error_rate
	benchmark: 
		"benchmarks/valik_rep{rep}_e{er}.txt"
	shell:
		"valik search --index {input.ibf} --ref-meta {input.ref_meta} --query-meta {input.query_meta} --query {input.query} --error-rate {params.e} --pattern {min_len} --overlap {overlap} --threads {threads} --output {output}"

