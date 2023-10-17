#!/bin/bash

# Variables for resources; default to previous values if not specified
JOB_NAME=${JOB_NAME:-trimmomatic}
TIME=${TIME:-04:00:00}
NTASKS=${NTASKS:-1}
CPUS=${CPUS:-16}
MEM=${MEM:-32G}
PARTITION=${PARTITION:-normal}

#SBATCH --job-name=$JOB_NAME
#SBATCH --time=$TIME
#SBATCH --ntasks=$NTASKS
#SBATCH --cpus-per-task=$CPUS
#SBATCH --mem=$MEM
#SBATCH --partition=$PARTITION

# Module load
ml Trimmomatic/0.39-Java-11
ml FastQC/0.11.9-Java-11

# Variables passed from command line
ID=$1
R1_INPUT=$2
R2_INPUT=$3
TRIMMOMATIC_OPTIONS=${4:-"ILLUMINACLIP:/cluster/software/Trimmomatic/0.39-Java-11/adapters/TruSeq3-PE-2.fa:2:30:10 SLIDINGWINDOW:4:30 MINLEN:80"}

# Ensure the directories exist
mkdir -p 1_fastqc/before_trim/${ID}
mkdir -p 1_fastqc/after_trim/${ID}
mkdir -p 2_trimmomatic/${ID}

fastqc -o 1_fastqc/before_trim/${ID} --threads $CPUS $R1_INPUT $R2_INPUT

echo $TRIMMOMATIC_OPTIONS

# Paths for output files
R1_PAIRED_OUTPUT=2_trimmomatic/${ID}/${ID}.R1.paired.trimmed.WL4.WQ30.ML80.fastq.gz
R1_UNPAIRED_OUTPUT=2_trimmomatic/${ID}/${ID}.R1.unpaired.trimmed.WL4.WQ30.ML80.fastq.gz
R2_PAIRED_OUTPUT=2_trimmomatic/${ID}/${ID}.R2.paired.trimmed.WL4.WQ30.ML80.fastq.gz
R2_UNPAIRED_OUTPUT=2_trimmomatic/${ID}/${ID}.R2.unpaired.trimmed.WL4.WQ30.ML80.fastq.gz

# Run trimmomatic
java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE -threads $CPUS -phred33 \
    $R1_INPUT $R2_INPUT \
    $R1_PAIRED_OUTPUT $R1_UNPAIRED_OUTPUT \
    $R2_PAIRED_OUTPUT $R2_UNPAIRED_OUTPUT \
    ${TRIMMOMATIC_OPTIONS}

fastqc -o 1_fastqc/after_trim/${ID} --threads $CPUS $R1_PAIRED_OUTPUT $R2_PAIRED_OUTPUT
