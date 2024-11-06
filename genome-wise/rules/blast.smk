blast_log = "../blast/blast.time"
f = open(blast_log, "a")
f.write("time\tmem\terror-code\tcommand\tthreads\tevalue\tk\n")
f.close()

rule blast_index:
	input:
		config["ref"]
	output:
		config["ref"] + ".ndb"
	shell:
		"""
		( /usr/bin/time -a -o {blast_log} -f "%e\t%M\t%x\tblast-index" makeblastdb -dbtype nucl -in {input})
		"""

rule blast_search:
	input:
		ref = config["ref"],
		db = config["ref"] + ".ndb",
		query = config["query"]
	output:
		"../blast/" + run_id + "_e{ev}_k{k}.txt"
	shell:
		"""
		mkdir -p blast
		/usr/bin/time -a -o {blast_log} -f "%e\t%M\t%x\tblast-search" \
			blastn -db {input.ref} -query {input.query} \
				-outfmt "6 sseqid sstart send pident sstrand evalue qseqid qstart qend" \
				-word_size {wildcards.k} -evalue {wildcards.ev} -out {output}
		"""
		
