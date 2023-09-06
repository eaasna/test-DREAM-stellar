rule valik_shared_ptr_search:
	input:
		mutex = "search/consolidated_e{er}.gff",
		ibf = "/dev/shm/valik.index",
		query = "queries/e{er}.fastq",
		ref_meta = "split/ref.txt",
		seg_meta = "split/ref_seg.txt"
	output:
		"search/shared_ptr_e{er}.gff"
	threads: search_threads
	params:
		e = get_search_error_count,
		valik = VALIK_SPLIT
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-shared-ptr-search\t{threads}" {params.valik} search --time --cart_max_capacity {cart_capacity} --max_queued_carts {queued_carts} --index {input.ibf} --ref-meta {input.ref_meta} --seg-meta {input.seg_meta} --query {input.query} --error {params.e} --pattern {pattern} --overlap {overlap} --threads {threads} --output {output})
		"""

rule valik_shared_ptr_consolidate:
	input:
		alignment = "search/shared_ptr_e{er}.gff",
		ref_meta = "split/ref.txt",
		seg_meta = "split/ref_seg.txt"
	output:
		"search/consolidated_shared_ptr_e{er}.gff"
	threads: 1
	params:
		e = get_search_error_count,
		valik = VALIK_SPLIT
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-shared-ptr-consolidate\t{threads}" {params.valik} consolidate --input {input.alignment} --ref-meta {input.ref_meta} --output {output})
		"""

