rule match_list:
	input:
		"{b}/stellar/e{er}.gff"	
	output:
		"{b}/stellar/e{er}.txt"
	script:
		"""
		cut -d ";" -f 1 {input} | awk "{{print \$1,\$9}}" > {output}
		"""

rule find_accuracy:
	input:
		stellar_matches = "{b}/stellar/e{er}.txt",
		valik_matches = "{b}/search/e{er}.out"
	output:
		expand("{{b}}/e{{er}}_p{p}_search_accuracy.tsv", p = p_max)
	script:
		"../scripts/assess_accuracy.py"
		
	
