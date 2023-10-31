rule blast_index:
	input:
		"ref_rep{rep}.fasta"
	output: 
		"ref_rep{rep}.fasta.ndb"
	benchmark:
		"benchmarks/blast_index_rep{rep}.txt"
	shell:
		"""
		makeblastdb -dbtype nucl -in {input}
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
		blastn -db {input.ref} -query {input.query} -outfmt "6 sseqid sstart send pident sstrand evalue qseqid qstart qend" -out {output}
		"""
		
		
