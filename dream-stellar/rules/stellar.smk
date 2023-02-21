rule convert_to_fasta:
	input:
		fastq = "queries/e{er}.fastq"
	output:
		fasta = "queries/e{er}.fasta"
	shell:
		"sed -n '1~4s/^@/>/p;2~4p' {input} > {output}"

rule stellar_search:
	input:
		ref = "ref.fasta",
		query = "queries/e{er}.fasta"
	output:
		"stellar/e{er}.gff"
	params:
		e = get_search_error_rate
	shell:
		"""
		( /usr/bin/time -a -o stellar.time -f "%e\t%M\t%x\t%C" /home/evelin/DREAM-Stellar/stellar/build/bin/stellar --verbose {input.ref} {input.query} -e {params.e} -l {pattern}  -o {output})
		"""
	
	#	"""
	#	( /usr/bin/time -a -o stellar.time -f "%e\t%M\t%x\t%C" stellar --verbose {input.ref} {input.query} --sequenceOfInterest 0 --segmentBegin 0 --segmentEnd 10000 -e {params.e} -l {pattern} -a dna -o {output})
#		"""
