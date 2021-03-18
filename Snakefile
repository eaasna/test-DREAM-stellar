#load  samples  into  table
import  pandas  as pd
import os

configfile: "config.yaml"
with open(config["bins"]) as f:
    bins = f.read().splitlines()

rule make_all:
	input:
		expand("stellar/{bin}.gff", bin = bins),
		"raptor/index.raptor"
	shell:
		"""
		echo 'Done'
		"""

include: "rules/stellar.smk"
include: "rules/raptor.smk"
