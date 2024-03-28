rule ref_to_dna4:
	input:
		"/buffer/ag_abi/evelina/hs37d5.fa"
	output:
		"/buffer/ag_abi/evelina/human_dna4.fa"
	shell:      
		"st_dna5todna4 {input} > {output}"

rule query_to_dna4:
	input:
		"/buffer/ag_abi/evelina/mouse/GCF_000001635.27_GRCm39_genomic.fna"
	output:
		"/buffer/ag_abi/evelina/mouse/dna4.fa"
	shell:      
		"st_dna5todna4 {input} > {output}"

