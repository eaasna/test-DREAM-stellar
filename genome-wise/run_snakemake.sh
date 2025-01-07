#!/bin/bash


snakemake --configfiles mouse_l50_config.yaml mouse_blast_config.yaml mouse_lastz_config.yaml mouse_dream_config.yaml --snakefile Snakefile_dream -n 
