import os
rule ref_to_dna4:
	input:
		config["ref"]
	output:
		os.path.split(config["ref"])[0] + "/dna4.fasta"
	shell:      
		"st_dna5todna4 {input} > {output}"

rule query_to_dna4:
	input:
		config["query"]
	output:
		os.path.split(config["query"])[0] + "/dna4.fasta"
	shell:      
		"st_dna5todna4 {input} > {output}"

# still concat scaffolds manually

