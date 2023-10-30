f = open("blast.time", "a")
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\n")
f.close()

rule blast_index:
	input:
		"genomeA_rep{rep}.fasta"
	output: 
		"genomeA_rep{rep}.fasta.ndb"
	shell:
		"""
		( /usr/bin/time -a -o blast.time -f "%e\t%M\t%x\tblast-index" makeblastdb -dbtype nucl -in {input})
		"""

rule blast_search:
	input:
		ref = "genomeA_rep{rep}.fasta",
		db = "genomeA_rep{rep}.fasta.ndb",
		query = "genomeB_rep{rep}.fasta"
	output:
		"blast/rep{rep}.tsv"
	shell:
		"""
		mkdir -p blast
		( /usr/bin/time -a -o blast.time -f "%e\t%M\t%x\tblast-search" blastn -db {input.ref} -query {input.query} -outfmt "6 sseqid sstart send pident sstrand evalue qseqid qstart qend" -out {output})
		"""
		
		
