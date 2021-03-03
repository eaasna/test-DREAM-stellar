#load  samples  into  table
import  pandas  as pd
import os

configfile: "config.yaml"
bins = pd.read_csv(config["bins"])

rule make_all:
	input:
		expand("stellar/{bin}.gff", bin = bins)
	shell:
		"""
		echo 'Done'
		"""

include: "rules/stellar.smk"
