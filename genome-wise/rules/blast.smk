blast_log = "../" + prefix + "/blast.time"
f = open(blast_log, "a")
f.write("time\tmem\terror-code\tcommand\tthreads\tevalue\tk\tmatches\n")
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
		"../" + prefix + "/" + run_id + "_e{ev}_k{k}.txt"
	threads: 8
	params: 
		percid = percid_from_k
	shell:
		"""
		mkdir -p blast
		/usr/bin/time -a -o {blast_log} -f "%e\t%M\t%x\tblast-search\t{threads}\t{wildcards.ev}\t{wildcards.k}" \
			blastn -db {input.ref} -query {input.query} -num_threads {threads} \
				-perc_identity {params.percid} \
				-outfmt "6 sseqid sstart send pident sstrand evalue qseqid qstart qend" \
				-word_size {wildcards.k} -evalue {wildcards.ev} -out {output}

		truncate -s -1 {blast_log}
		wc -l {output} | awk '{{print "\t" $1}}' >> {blast_log}
		"""
		
