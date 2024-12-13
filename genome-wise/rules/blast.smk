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
	shell:
		"""
		mkdir -p blast
		/usr/bin/time -a -o {blast_log} -f "%e\t%M\t%x\tblast-search\t{threads}\t{wildcards.ev}\t{wildcards.k}" \
			blastn -db {input.ref} -query {input.query} -num_threads {threads} \
				-outfmt "6 sseqid sstart send pident sstrand evalue qseqid qstart qend" \
				-word_size {wildcards.k} -evalue {wildcards.ev} \
				-dust "no" -soft_masking "no" -out {output}

		truncate -s -1 {blast_log}
		wc -l {output} | awk '{{print "\t" $1}}' >> {blast_log}
		"""

rule blast_compare_stellar:
	input:
		ref_meta = "error_rates/meta/b1024_fpr0.005_l150.bin",
		test_files = expand(blast_out + "/" + run_id + "_e{ev}_k{k}.bed", ev = evalues, k = blast_kmer_lengths),
		truth_files = expand(stellar_out + "/" + run_id + "_l{l}_e{er}_rp{rp}_rl{rl}.gff", l = min_lens, er = errors, rp = repeat_periods, rl = repeat_lengths) 
	output:
		"blast.kmer.accuracy"
	threads: workflow.cores
	params:
		min_len = min(min_lens)
	shell:
		"""
		echo -e "test-file\tmatches\ttruth-set-matches\ttrue-matches\tmissed\tmin-overlap\ttruth-file" > {output}
		for test in {input.test_files}
		do
			for truth in {input.truth_files}
			do
			
			match_count=`wc -l $test | awk '{{print $1}}'`
			echo -e "$test\t$match_count\t" >> {output}
			
			truncate -s -1 {output}
			../../scripts/search_accuracy.sh $truth $test {params.min_len} {min_overlap} {input.ref_meta} tmp.log
			tail -n 1 tmp.log >> {output}
			rm tmp.log
	
			truncate -s -1 {output}
			echo -e "\t{min_overlap}\t$truth" >> {output}
			done
		done
		"""

