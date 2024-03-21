f = open("blast.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
	f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\n")
f.close()

rule blast_index:
	input:
		"{b}/ref.fasta"
	output: 
		"{b}/ref.fasta.ndb"
	benchmark:
		"benchmarks/blast_build_b{b}.txt"
	shell:
		"""
		( /usr/bin/time -a -o blast.time -f "%e\t%M\t%x\tblast-db\t{threads}"	makeblastdb -dbtype nucl -in {input})
		"""

rule blast_search:
	input:
		ref = "{b}/ref.fasta",
		db = "{b}/ref.fasta.ndb",
		query = "{b}/queries/e{er}.fasta"
	output:
		"{b}/blast/e{er}.tsv"
	benchmark:
		"benchmarks/blast_e{er}_b{b}.txt"
	shell:
		"""
		mkdir -p blast
		( timeout 1h /usr/bin/time -a -o blast.time -f "%e\t%M\t%x\tblast-seach\t{threads}\t{wildcards.er}"	blastn -db {input.ref} -query {input.query} -outfmt "6 sseqid sstart send pident sstrand evalue qseqid qstart qend" -out {output} || touch {output} )
		"""
		
