f = open("valik.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
	f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\n")
f.close()

rule valik_split_ref:
	input:
		"ref.fasta"
	output: 
		db_meta = "split/ref.txt",
		seg_meta = "split/ref_seg.txt"
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tsplit-ref\t{threads}" valik split {input} --db-meta {output.db_meta} --seg-meta {output.seg_meta} --overlap {max_len} --seg-count {bins})
		"""

rule valik_split_query:
	input:
		query = "query.fasta",
	output: 
		db_meta = "split/query.txt",
		seg_meta = "split/query_seg.txt",
		segments = "query.segments.fasta"
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tsplit-query\t{threads}" valik split {input} --write-query --db-meta {output.db_meta} --seg-meta {output.seg_meta} --overlap {max_len} --seg-count {query_seg_count})
		"""

rule valik_build:
	input:
		fasta = "ref.fasta",
		ref_meta = "split/ref.txt",
		seg_meta = "split/ref_seg.txt"
	output: 
		ibf = temp("/dev/shm/valik.index")
	threads: 8
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-build\t{threads}" valik build {input.fasta} --seg-meta {input.seg_meta} --ref-meta {input.ref_meta} --from-segments --window {w} --kmer {k} --output {output.ibf} --size {size} --threads {threads})
		"""

