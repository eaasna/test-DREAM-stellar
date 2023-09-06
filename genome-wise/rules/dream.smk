PTR_VALIK="/group/ag_abi/evelina/valik/build_split/bin/valik"

rule valik_split_ref:
	input:
		"ref_rep{rep}.fasta"
	output: 
		ref_meta = "meta/ref_rep{rep}.txt",
		seg_meta = "meta/ref_seg_rep{rep}.txt"
	params:
		valik=PTR_VALIK
	shell:
		"{params.valik} split {input} --db-meta {output.ref_meta} --seg-meta {output.seg_meta} --overlap {min_len} -n {bins}"

rule valik_split_query:
	input:
		"query/with_insertions_rep{rep}_e{er}.fasta"
	output: 
		query_meta = "meta/query_rep{rep}_e{er}.txt",
		seg_meta = "meta/query_seg_rep{rep}_e{er}.txt"
	params:
		valik=PTR_VALIK
	shell:
		"{params.valik} split {input} --db-meta {output.query_meta} --seg-meta {output.seg_meta} --overlap {min_len} -n {bins}"

rule valik_build:
	input:
		ref = "ref_rep{rep}.fasta",
		ref_meta = "meta/ref_rep{rep}.txt",
		seg_meta = "meta/ref_seg_rep{rep}.txt"
	output: 
		"rep{rep}.index"
	threads: 8
	params:
		valik=PTR_VALIK
	shell:
		"{params.valik} build --from-segments {input.ref} --threads {threads} --window {w} --kmer {k} --output {output} --size {size} --seg-meta {input.seg_meta} --ref-meta {input.ref_meta}"

rule valik_search:
	input:
		ibf = "rep{rep}.index",
		query = "query/with_insertions_rep{rep}_e{er}.fasta",
		query_seg = "meta/query_seg_rep{rep}_e{er}.txt",
		ref_meta = "meta/ref_rep{rep}.txt",
		ref_seg = "meta/ref_seg_rep{rep}.txt"
	output:
		"valik/rep{rep}_e{er}.gff"
	threads: 8
	params:
		e = get_search_error_count,
		valik=PTR_VALIK
	benchmark: 
		"benchmarks/valik_rep{rep}_e{er}.txt"
	shell:
		"{params.valik} search --index {input.ibf} --ref-meta {input.ref_meta} --seg-meta {input.ref_seg} --query-meta {input.query_seg} --query {input.query} --error {params.e} --pattern {min_len} --overlap {overlap} --threads {threads} --output {output}"

rule valik_consolidate:
	input:
		alignment = "valik/rep{rep}_e{er}.gff",
		ref_meta = "meta/ref_rep{rep}.txt"
	output:
		"valik/final_rep{rep}_e{er}.gff"
	threads: 1
	params:
		valik=PTR_VALIK
	shell:
		"""
		{params.valik} consolidate --input {input.alignment} --ref-meta {input.ref_meta} --output {output}
		"""
	
