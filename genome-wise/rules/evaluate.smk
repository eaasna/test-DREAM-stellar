rule stellar_accuracy:
	input:
		search = "stellar_e{er}.gff"
	output:
		temp("evaluation/stellar_e{er}.tsv")
	shell:
		"scripts/evaluation_log.sh {wildcards.er} {input} {output}"

rule stellar_table1:
	input:
		benchmark = expand("benchmarks/stellar_e{er}.txt", er=error_rates),
		evaluation = expand("evaluation/stellar_e{er}.tsv", er=error_rates)
	output:
		"stellar_table1.tsv"
	params:
		repeats = n,	# set as parameters to use in .py
		error_rates = error_rates,
		prefix = "stellar"
	script:
		"../scripts/make_table1.py"

rule dream_accuracy:
	input:
		search = "valik_e{er}_b{b}.gff",
	output:
		temp("evaluation/valik_e{er}_b{b}.tsv")
	shell:
		"scripts/evaluation_log.sh {wildcards.er} {input} {output}"

rule valik_table1:
	input:
                benchmark = expand("benchmarks/valik_e{er}_b{{b}}.txt", er=error_rates),
                evaluation = expand("evaluation/valik_e{er}_b{{b}}.tsv", er=error_rates)
	output:
		"valik_table1_b{b}.tsv"
	params:
		repeats = n,	# set as parameters to use in .py,
		error_rates = error_rates,
		prefix = "valik"
	script:
		"../scripts/make_table1.py"

rule blast_accuracy:
	input:
		search = "blast.tsv",
	output:
		"evaluation/blast.tsv"
	shell:
		"scripts/blast_evaluation_log.sh {input} {output}"

rule blast_table1:
	input:
                benchmark = expand("benchmarks/blast.txt", er=error_rates),
                evaluation = expand("evaluation/blast.tsv", er=error_rates)
	output:
		"blast_table1.tsv"
	params:
		repeats = n	# set as parameters to use in .py
	script:
		"../scripts/make_blast_table1.py"
