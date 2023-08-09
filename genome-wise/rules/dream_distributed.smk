rule valik_distributed_search:
	input:
		ibf = "/dev/shm/valik.index",
		query = "query.segments.fasta",
		ref_meta = "split/ref.txt",
		seg_meta = "split/ref_seg.txt"
	output:
		"search/distributed_e{er}.gff"
	threads: search_threads
	params:
		e = get_search_error_count
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-distributed-search\t{threads}" valik search --time --cart_max_capacity {cart_capacity} --max_queued_carts {queued_carts} --index {input.ibf} --ref-meta {input.ref_meta} --seg-meta {input.seg_meta} --query {input.query} --error {params.e} --pattern {pattern} --overlap {overlap} --threads {threads} --output {output})
		"""
		
rule valik_distributed_consolidate:
	input:
		alignment = "search/distributed_e{er}.gff",
		ref_meta = "split/ref.txt",
		seg_meta = "split/ref_seg.txt"
	output:
		"search/consolidated_distributed_e{er}.gff"
	threads: 1
	params:
		e = get_search_error_count
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-distributed-consolidate\t{threads}" valik consolidate --input {input.alignment} --ref-meta {input.ref_meta} --output {output})
		"""

