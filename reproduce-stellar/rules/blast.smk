f = open("blast.time", "a")
f.write("time\tmem\texit-code\tcommand\tthreads\tevalue\tkmer-size\n")
f.close()

rule blast_index:
	input:
		"ref_rep{rep}.fasta"
	output: 
		"ref_rep{rep}.fasta.ndb"
	benchmark:
		"benchmarks/blast_build_rep{rep}.txt"
	threads: workflow.cores
	shell:
		"""
		( /usr/bin/time -a -o blast.time -f "%e\t%M\t%x\tblast-db\t{threads}"	makeblastdb -dbtype nucl -in {input})
		"""

def blast_kmer_size(wildcards):
	errors = round(int(min_len) * float(wildcards.er))
	for k in range(51, 6, -1):
		if ((int(min_len) - k + 1 - errors * k ) > 2 ):
			return k

default_k = 28
evalue = 10
rule blast_search:
	input:
		ref = "ref_rep{rep}.fasta",
		db = "ref_rep{rep}.fasta.ndb",
		query = "query/rep{rep}_e{er}.fasta"
	output:
		"blast/rep{rep}_e{er}.txt"
	params:
		k = blast_kmer_size
	threads: workflow.cores
	benchmark:
		"benchmarks/blast_rep{rep}_e{er}.txt"
	shell:
		"""
		mkdir -p blast
		( timeout 12h /usr/bin/time -a -o blast.time -f "%e\t%M\t%x\tblast-seach\t{threads}\t{evalue}\t{default_k}"	blastn -db {input.ref} -query {input.query} -evalue {evalue} -word_size {params.k} -outfmt "6 sseqid sstart send pident sstrand evalue qseqid qstart qend" -out {output} || touch {output} )
		"""
		
