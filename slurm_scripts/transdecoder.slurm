#!/bin/bash

# Variables for resources; default to previous values if not specified
JOB_NAME=${JOB_NAME:-trimmomatic}
TIME=${TIME:-02:00:00}
NTASKS=${NTASKS:-1}
CPUS=${CPUS:-4}
MEM=${MEM:-16G}
PARTITION=${PARTITION:-normal}

#SBATCH --job-name=$JOB_NAME
#SBATCH --time=$TIME
#SBATCH --ntasks=$NTASKS
#SBATCH --cpus-per-task=$CPUS
#SBATCH --mem=$MEM
#SBATCH --partition=$PARTITION

# Set variables
ID=$1
TRANSDECODER=/cluster/projects/nn9825k/software/TransDecoder-TransDecoder-v5.7.0/TransDecoder.LongOrfs
INPUT_DIR=3_trinity/${ID}
OUTPUT_DIR=5_transdecoder/${ID}

# Do the work
mkdir -p $OUTPUT_DIR

${TRANSDECODER} -m 50 -t ${INPUT_DIR}/${ID}_trinity.Trinity.fasta --output_dir ${OUTPUT_DIR}

sed 's/\ .*//g' ${OUTPUT_DIR}/longest_orfs.pep | sed "s/>\(.*\)/>${ID}\_\1/g" > ${OUTPUT_DIR}/${ID}.trinity.AA.fa