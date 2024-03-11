f = open("blast.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
	f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\n")
f.close()

rule blast_index:
	input:
		"ref_rep{rep}.fasta"
	output: 
		"ref_rep{rep}.fasta.ndb"
	benchmark:
		"benchmarks/blast_build_rep{rep}.txt"
	shell:
		"""
		( /usr/bin/time -a -o blast.time -f "%e\t%M\t%x\tblast-db\t{threads}"	makeblastdb -dbtype nucl -in {input})
		"""

rule blast_search:
	input:
		ref = "ref_rep{rep}.fasta",
		db = "ref_rep{rep}.fasta.ndb",
		query = "query/rep{rep}_e{er}.fasta"
	output:
		"blast/rep{rep}_e{er}.tsv"
	benchmark:
		"benchmarks/blast_rep{rep}_e{er}.txt"
	shell:
		"""
		mkdir -p blast
		( timeout 1h /usr/bin/time -a -o blast.time -f "%e\t%M\t%x\tblast-seach\t{threads}\t{wildcards.er}"	blastn -db {input.ref} -query {input.query} -outfmt "6 sseqid sstart send pident sstrand evalue qseqid qstart qend" -out {output} || touch {output} )
		"""
		
