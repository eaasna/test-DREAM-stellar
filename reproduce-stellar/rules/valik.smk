bins = config["ibf_bins"]
w = config["window"]
k = config["kmer_length"]
size = config["ibf_size"]

rule valik_split:
        input:
                "ref_rep{rep}.fasta"
        output: 
                ref_meta = "valik/ref_rep{rep}.txt",
		seg_meta = "valik/seg_rep{rep}.txt"
        shell:
                "valik split {input} --reference-output {output.ref_meta} --segment-output {output.seg_meta} --overlap {max_len} --bins {bins}"

rule valik_build:
	input:
		ref = "ref_rep{rep}.fasta",
		ref_meta = "valik/ref_rep{rep}.txt",
		seg_meta = "valik/seg_rep{rep}.txt"
	output: 
		"valik/rep{rep}.index"
	threads: 8
	shell:
		"valik build --from-segments {input.ref} --threads {threads} --window {w} --kmer {k} --output {output} --size {size} --seg-path {input.seg_meta} --ref_path {input.ref_meta}"

# TODO: need to split the query as well 
rule valik_search:
	input:
		ibf = "valik/rep{rep}.index",
		query = "query_with"
	output:
		"valik/search_rep{rep}.out"
	threads: 8
	shell:
		"valik search --index {input.ibf}"
		
