rule valik_build:
	input:
		fasta = expand("bins/bin_{bin}.fasta", bin = bin_list),
		meta = "bin_paths.txt"
	output: 
		ibf = temp("{size}/valik.index")
	threads: 16
	shell:
		"""
		/usr/bin/time -a -o build.time -f "%e\t%M\t%x\t%C" valik build {input.meta} --threads {threads} --window {w} --kmer {k} --output {output.ibf} --size {wildcards.size}
		"""

rule valik_search:
	input:
		ibf = "{size}/valik.index",
		query = "queries/e{sim_errors}.fastq"
	output:
		"{size}/e{sim_errors}_o{o}.out"
	threads: 4
	shell:
		"""
		/usr/bin/time -a -o {wildcards.o}_valik.time -f "%e\t%M\t%x\t%C" valik search --index {input.ibf} --query {input.query} --error {search_errors} --pattern {pattern} --overlap {wildcards.o} --threads {threads} --output {output}
		"""	

