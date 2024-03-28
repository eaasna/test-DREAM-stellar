f = open("blast.time", "a")
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\n")
f.close()

rule blast_index:
	input:
		"/buffer/ag_abi/evelina/human_dna4.fa"
	output: 
		"/buffer/ag_abi/evelina/human_dna4.fa.ndb"
	shell:
		"""
		( /usr/bin/time -a -o blast.time -f "%e\t%M\t%x\tblast-index" makeblastdb -dbtype nucl -in {input})
		"""

rule blast_search:
	input:
		ref = "/buffer/ag_abi/evelina/human_dna4.fa",
		db = "/buffer/ag_abi/evelina/human_dna4.fa.ndb",
		query = "/buffer/ag_abi/evelina/mouse/dna4.fa"
	output:
		"blast.tsv"
	benchmark:
		"benchmarks/blast.txt"
	shell:
		"""
		mkdir -p blast
		( /usr/bin/time -a -o blast.time -f "%e\t%M\t%x\tblast-search" blastn -db {input.ref} -query {input.query} -outfmt "6 sseqid sstart send pident sstrand evalue qseqid qstart qend" -out {output})
		"""
		
		
