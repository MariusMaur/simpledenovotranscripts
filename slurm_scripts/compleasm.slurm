#!/bin/bash

# Variables for resources; default to previous values if not specified
JOB_NAME=${JOB_NAME:-compleasm}
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

# Variables passed from command line
ID=$1
LINEAGE=$2

# Output directory and input transcriptome based on the sample ID
COMPLEASM=/cluster/projects/nn9825k/marimaur/X_programs/compleasm_kit/compleasm.py
OUTPUT_DIR="4_compleasm/${ID}_compleasm"
TRANSCRIPTOME="3_trinity/${ID}/${ID}_trinity.Trinity.fasta"


# Ensure the output directory exists
mkdir -p ${OUTPUT_DIR}

# Run Compleasm 
python $COMPLEASM run -a ${TRANSCRIPTOME} -o ${OUTPUT_DIR} -l ${LINEAGE} -L /cluster/projects/nn9825k/marimaur/databases/mb_downloads


