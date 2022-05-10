rule valik_split_ref:
	input:
		"ref.fasta"
	output: 
		ref_meta = "split/ref.txt",
		seg_meta = "split/seg.txt"
	shell:
		"""
		( /usr/bin/time -a -o valik_split.time -f "%e\t%M\t%x\t%C" valik split {input} --reference-output {output.ref_meta} --segment-output {output.seg_meta} --overlap {max_len} --bins {bins})
		"""

# assuming a single reference sequence
rule create_seg_files:
	input:
		ref = "ref.fasta",
		seg_meta = "split/seg.txt"
	output:
		fasta = expand("/dev/shm/seg/seg_{bin}.fasta", bin = bin_list),
		meta = "split/bin_paths.txt"
	params:
		out_prefix = "/dev/shm/seg/seg_"
	benchmark:
		repeat("create_seg_files.time", 3)
	script:
		"../scripts/create_seg_files.py"

rule valik_build:
	input:
		fasta = expand("/dev/shm/seg/seg_{bin}.fasta", bin = bin_list),
		meta = "split/bin_paths.txt"
	output: 
		ibf = "valik.index"
	threads: 8
	shell:
		"""
		( /usr/bin/time -a -o valik_build.time -f "%e\t%M\t%x\t%C" valik build {input.meta} --threads {threads} --window {w} --kmer {k} --output {output.ibf} --size {size})
		"""

rule bin_query_files:
	input: 
		"queries/e{er}.fastq"
	output:
		"e{er}_bin_query_paths.txt"
	shell:
		"../scripts/bin_query_file_list.sh {bins} {wildcards.er} {output}"

rule valik_search:
	input:
		ibf = "valik.index",
		query = "queries/e{er}.fastq",
		bin_queries = "e{er}_bin_query_paths.txt"
	output:
		read_bins = "search/e{er}.out",
		bin_reads = expand("/dev/shm/queries/bin_{bin}_e{{er}}.fasta", bin = bin_list)
	threads: 8
	params:
		e = get_search_error_count
	shell:
		"""
		mkdir -p /dev/shm/queries
		( /usr/bin/time -a -o valik_search.time -f "%e\t%M\t%x\t%C" valik search --index {input.ibf} --bin-query {input.bin_queries} --query {input.query} --error {params.e} --pattern {pattern} --overlap {overlap} --threads {threads} --output {output.read_bins})
		"""
		
