rule match_list:
	input:
		"stellar/bin_{bin}_e{sim_errors}.gff"
	output:
		"matches/bin_{bin}_e{sim_errors}.txt"
	shell:
		"""
		cut -d ";" -f 1 {input} | awk "{{print \$1,\$9}}" > {output}
		"""

