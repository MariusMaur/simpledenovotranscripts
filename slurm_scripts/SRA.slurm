#!/bin/bash

# Variables for resources; default to previous values if not specified
JOB_NAME=${JOB_NAME:-sra}
TIME=${TIME:-08:00:00}
NTASKS=${NTASKS:-1}
CPUS=${CPUS:-4}
MEM=${MEM:-8G}
PARTITION=${PARTITION:-normal}

#SBATCH --job-name=$JOB_NAME
#SBATCH --time=$TIME
#SBATCH --ntasks=$NTASKS
#SBATCH --cpus-per-task=$CPUS
#SBATCH --mem=$MEM
#SBATCH --partition=$PARTITION

# Load the environment and variables
ml SRA-Toolkit/3.0.3-gompi-2022a
ID=$1
SRA_ACCESSION=$2

# Define the output directory
OUTPUT_DIR="SRA_reads"

# Ensure the output directory exists
mkdir -p $OUTPUT_DIR/${ID}

cd SRA_prefetch

fasterq-dump ${SRA_ACCESSION} --split-files --threads 4

mv ${SRA_ACCESSION}_1.fastq ../${OUTPUT_DIR}/${ID}/${ID}_R1.fastq
mv ${SRA_ACCESSION}_2.fastq ../${OUTPUT_DIR}/${ID}/${ID}_R2.fastq

