blast_log = blast_out + "/blast.time"
f = open(blast_log, "a")
f.write("time\tmem\terror-code\tcommand\tthreads\tevalue\tk\tmatches\n")
f.close()

rule blast_index:
	input:
		dir_path(config["ref"]) + "dna4.fasta"
	output:
		dir_path(config["ref"]) + "dna4.fasta.ndb"
	shell:
		"""
		( /usr/bin/time -a -o {blast_log} -f "%e\t%M\t%x\tblast-index" makeblastdb -dbtype nucl -in {input})
		"""

rule blast_search:
	input:
		ref = dir_path(config["ref"]) + "dna4.fasta",
		db = dir_path(config["ref"]) + "dna4.fasta.ndb",
		query = dir_path(config["query"]) + "dna4.fasta"
	output:
		blast_out + "/" + run_id + "_e{ev}_k{k}.bed"
	threads: workflow.cores
	params:
		perc_id = percid_from_k
	shell:
		"""
		mkdir -p blast
		/usr/bin/time -a -o {blast_log} -f "%e\t%M\t%x\tblast-search\t{threads}\t{wildcards.ev}\t{wildcards.k}" \
			blastn -db {input.ref} -query {input.query} -num_threads {threads} \
				-outfmt "6 sseqid sstart send pident sstrand evalue qseqid qstart qend" \
				-word_size {wildcards.k} -evalue {wildcards.ev}  \
				-dust "no" -soft_masking "no" -out {output}
		truncate -s -1 {blast_log}
		wc -l {output} | awk '{{print "\t" $1}}' >> {blast_log}
		"""

#-perc_identity {params.perc_id}
