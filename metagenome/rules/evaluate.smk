rule stellar_accuracy:
	input:
		search = "{b}/stellar/e{er}.gff",
		truth = "{b}/ground_truth/e{er}.tsv"
	output:
		"evaluation/stellar_e{er}_b{b}.tsv"
	params:
		min_overlap = min_overlap
	shell:
		"../scripts/evaluate_search.sh {input.search} {input.truth} {params.min_overlap} {min_len} {output} gff"

rule stellar_table1:
	input:
                benchmark = expand("benchmarks/stellar_e{er}_b{{b}}.txt", er=error_rates),
                evaluation = expand("evaluation/stellar_e{er}_b{{b}}.tsv", er=error_rates)
	output:
		"{b}/stellar_table1.tsv"
	params:
		repeats = n,	# set as parameters to use in .py
		prefix = "stellar",
		error_rates = error_rates
	script:
		"../scripts/make_stellar_table1.py"

rule dream_accuracy:
	input:
		search = "{b}/valik/e{er}.gff",
		truth = "{b}/ground_truth/e{er}.tsv"
	output:
		"evaluation/valik_e{er}_b{b}.tsv"
	params:
		min_overlap = min_overlap
	shell:
		"../scripts/evaluate_search.sh {input.search} {input.truth} {params.min_overlap} {min_len} {output} gff"

rule valik_table1:
	input:
                benchmark = expand("benchmarks/valik_e{er}_b{{b}}.txt", er=error_rates),
                evaluation = expand("evaluation/valik_e{er}_b{{b}}.tsv", er=error_rates)
	output:
		"{b}/valik_table1.tsv"
	params:
		repeats = n,	# set as parameters to use in .py,
		prefix = "valik",
		error_rates = error_rates
	script:
		"../scripts/make_stellar_table1.py"

rule blast_accuracy:
	input:
		search = "{b}/blast/e{er}.tsv",
		truth = "{b}/ground_truth/e{er}.tsv"
	output:
		"evaluation/blast_e{er}_b{b}.tsv"
	params:
		min_overlap = min_overlap
	shell:
		"../scripts/evaluate_search.sh {input.search} {input.truth} {params.min_overlap} {min_len} {output} tsv"

rule blast_table1:
	input:
                benchmark = expand("benchmarks/blast_e{er}_b{{b}}.txt", er=error_rates),
                evaluation = expand("evaluation/blast_e{er}_b{{b}}.tsv", er=error_rates)
	output:
		"{b}/blast_table1.tsv"
	params:
		repeats = n,	# set as parameters to use in .py
		prefix = "blast",
		error_rates = error_rates
	script:
		"../scripts/make_stellar_table1.py"
