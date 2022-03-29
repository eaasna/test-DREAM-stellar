rule simulate:
        output:
                ref = "ref.fasta",
                query = "query/one_line.fasta",
                matches = expand("local_matches/{er}.fastq", er=error_rates)
        shell:
                "./scripts/simulate.sh"

rule insert_matches:
        input:
                ref = "ref.fasta",
                query = "query/one_line.fasta",
                matches = "local_matches/{er}.fastq"
        output:
                query = "query/with_insertions_{er}.fasta",
                ground_truth = "ground_truth/{er}.tsv"
        script:
                "../scripts/insert_local_matches.py"

