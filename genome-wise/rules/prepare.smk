rule mask_query:
	input:
		config["query"]
	output:
		dir_path(config["query"]) + "masked.fasta"
	shell:
		"dust {input} > {output}"

rule ref_to_dna4:
	input:
		config["ref"]
	output:
		dir_path(config["ref"]) + "dna4.fasta"
	shell:      
		"st_dna5todna4 {input} > {output}"

rule query_to_dna4:
	input:
		dir_path(config["query"]) + "masked.fasta"
	output:
		dir_path(config["query"]) + "dna4.fasta"
	shell:      
		"st_dna5todna4 {input} > {output}"

