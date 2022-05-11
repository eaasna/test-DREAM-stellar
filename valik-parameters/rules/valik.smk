rule valik_build:
	input:
		fasta = expand("bins/bin_{bin}.fasta", bin = bin_list),
		meta = "bin_paths.txt"
	output: 
		ibf = temp("{size}/valik.index")
	threads: 16
	shell:
		"valik build {input.meta} --threads {threads} --window {w} --kmer {k} --output {output.ibf} --size {wildcards.size}"

rule valik_search:
	input:
		ibf = "{size}/valik.index",
		query = "queries/e{er}.fastq",
		bin_queries = "e{er}_bin_query_paths.txt"
	output:
		"{size}/e{er}_o{o}.out"
	threads: 16
	params:
		e = get_search_error_count
	shell:
		"""
		/usr/bin/time -a -o {wildcards.o}_valik.time -f "%e\t%M\t%x\t%C" valik search --index {input.ibf} --query {input.query} --bin-query {input.bin_queries} --error {params.e} --pattern {pattern} --overlap {wildcards.o} --threads {threads} --output {output}
		"""	

