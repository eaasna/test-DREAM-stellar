rule valik_split_ref:
	input:
		"ref.fasta"
	output: 
		ref_meta = "split/ref.txt",
		seg_meta = "split/seg.txt"
	shell:
		"""
		( /usr/bin/time -a -o valik_split.time -f "%e\t%M\t%x\t%C" valik split {input} --ref-meta {output.ref_meta} --seg-meta {output.seg_meta} --overlap {max_len} --bins {bins})
		"""

rule valik_build:
	input:
		fasta = "ref.fasta",
		ref_meta = "split/ref.txt",
		seg_meta = "split/seg.txt"
	output: 
		ibf = temp("/dev/shm/valik.index")
	threads: 8
	shell:
		"""
		( /usr/bin/time -a -o valik_build.time -f "%e\t%M\t%x\t%C" valik build {input.fasta} --seg-meta {input.seg_meta} --ref-meta {input.ref_meta} --from-segments --window {w} --kmer {k} --output {output.ibf} --size {size})
		"""

rule valik_search:
	input:
		ibf = "/dev/shm/valik.index",
		query = "queries/e{er}.fastq",
		seg_meta = "split/seg.txt"
	output:
		read_bins = "search/e{er}.gff"
	threads: 4
	params:
		e = get_search_error_count
	shell:
		"""
		( /usr/bin/time -a -o valik_search.time -f "%e\t%M\t%x\t%C" valik search --cart_max_capacity 1000 --index {input.ibf} --seg-meta {input.seg_meta} --query {input.query} --error {params.e} --pattern {pattern} --overlap {overlap} --threads {threads} --output {output.read_bins})
		"""
		
rule valik_consolidate:
	input:
		alignment = "search/e{er}.gff",
		ref_meta = "split/ref.txt",
		seg_meta = "split/seg.txt"
	output:
		"search/consolidated_e{er}.gff"
	threads: 1
	params:
		e = get_search_error_count
	shell:
		"""
		( /usr/bin/time -a -o valik_consolidate.time -f "%e\t%M\t%x\t%C" valik consolidate --input {input.alignment} --ref-meta {input.ref_meta} --output {output})
		"""
