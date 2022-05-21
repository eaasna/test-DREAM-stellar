rule valik_build:
	input:
		fasta = expand("{{b}}/bins/bin_{bin}.fasta", bin = bin_list),
		meta = "{b}/bin_paths.txt"
	output: 
		ibf = temp("/dev/shm/{b}/valik.index")
	threads: 16
	shell:
		"""
		( /usr/bin/time -a -o valik_build.time -f "%e\t%M\t%x\t%C" valik build {input.meta} --threads {threads} --window {w} --kmer {k} --output {output.ibf} --size {size} )
		"""

rule valik_search:
	input:
		ibf = "/dev/shm/{b}/valik.index",
		query = "{b}/queries/e{er}.fastq",
		bin_queries = "{b}/e{er}_bin_query_paths.txt"
	output:
		read_bins = "{b}/search/e{er}.out",
		bin_reads = expand("/dev/shm/{{b}}/queries/bin_{bin}_e{{er}}.fasta", bin = bin_list)
	threads: 16
	params:
		e = get_search_error_count
	shell:
		"""
		mkdir -p /dev/shm/{wildcards.b}/queries
		( /usr/bin/time -a -o valik_search.time -f "%e\t%M\t%x\t%C" valik search --time --p_max {p_max} --index {input.ibf} --bin-query {input.bin_queries} --query {input.query} --error {params.e} --pattern {pattern} --overlap {overlap} --threads {threads} --output {output.read_bins} )
		"""
		
