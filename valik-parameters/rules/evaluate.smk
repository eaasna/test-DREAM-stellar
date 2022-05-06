rule match_list:
	input:
		"stellar/bin_{bin}_e{er}.gff"
	output:
		"matches/bin_{bin}_e{er}.txt"
	shell:
		"""
		cut -d ";" -f 1 {input} | awk "{{print \$1,\$9}}" > {output}
		"""

