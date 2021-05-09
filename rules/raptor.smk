rule raptor_build:
	input:
		"../data/64/all_bin_paths.txt"
	output:
		"../data/64/index_{k}_80m.raptor"
	shell:
		"./../raptor_clone/build/bin/raptor build --kmer {wildcards.k} --window {wildcards.k} --size 80m --output {output} {input}"

rule raptor_search:
	input:
		index = "../data/64/index_{k}_80m.raptor",
		reads = "../data/64/reads_e{rer}_150/bin_33.fastq"
	output:
		"../data/64/output_e{rer}/bin_33_k{k}_p{p}_o{o}_e{e}.output"
	shell:
		"./../raptor_clone/build/bin/raptor search --kmer {wildcards.k} --window {wildcards.k} --error {wildcards.e} --pattern {wildcards.p} --overlap {wildcards.o} --index {input.index} --query {input.reads} --output {output}"	
