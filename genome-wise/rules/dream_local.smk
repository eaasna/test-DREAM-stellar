rule valik_local_search:
	input:
		dist_mutex = "search/consolidated_distributed_e{er}.gff",
		ibf = "/dev/shm/valik.index",
		query = "query.segments.fasta",
		ref_meta = "split/ref.txt",
		seg_meta = "split/ref_seg.txt"
	output:
		"search/local_e{er}.gff"
	threads: search_threads
	params:
		e = get_search_error_count
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-local-search\t{threads}" valik search --time --shared-memory --cart_max_capacity {cart_capacity} --max_queued_carts {queued_carts} --index {input.ibf} --ref-meta {input.ref_meta} --seg-meta {input.seg_meta} --query {input.query} --error {params.e} --pattern {pattern} --overlap {overlap} --threads {threads} --output {output})
		"""

rule valik_local_consolidate:
	input:
		alignment = "search/local_e{er}.gff",
		ref_meta = "split/ref.txt",
		seg_meta = "split/ref_seg.txt"
	output:
		"search/consolidated_local_e{er}.gff"
	threads: 1
	params:
		e = get_search_error_count
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-local-consolidate\t{threads}" valik consolidate --input {input.alignment} --ref-meta {input.ref_meta} --output {output})
		"""

