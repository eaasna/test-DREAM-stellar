f = open("valik.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
	f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\n")
f.close()


rule valik_split_ref:
	input:
		"ref.fasta"
	output: 
		ref_meta = "split/ref.txt",
		seg_meta = "split/seg.txt"
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-split\t{threads}" valik split {input} --ref-meta {output.ref_meta} --seg-meta {output.seg_meta} --overlap {max_len} --bins {bins})
		"""

rule valik_build:
	input:
		fasta = "ref.fasta",
		ref_meta = "split/ref.txt",
		seg_meta = "split/seg.txt"
	output: 
		ibf = temp("/dev/shm/valik.index")
	threads: 16
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-build\t{threads}" valik build {input.fasta} --seg-meta {input.seg_meta} --ref-meta {input.ref_meta} --from-segments --window {w} --kmer {k} --output {output.ibf} --size {size} --threads {threads})
		"""

rule valik_search:
	input:
		ibf = "/dev/shm/valik.index",
		query = "queries/e{er}.fastq",
		ref_meta = "split/ref.txt",
		seg_meta = "split/seg.txt"
	output:
		read_bins = "search/e{er}.gff"
	threads: 8
	params:
		e = get_search_error_count
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-search\t{threads}" valik search --cart_max_capacity {cart_capacity} --max_queued_carts {queued_carts} --index {input.ibf} --ref-meta {input.ref_meta} --seg-meta {input.seg_meta} --query {input.query} --error {params.e} --pattern {pattern} --overlap {overlap} --threads {threads} --output {output.read_bins})
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
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-consolidate\t{threads}" valik consolidate --input {input.alignment} --ref-meta {input.ref_meta} --output {output})
		"""
