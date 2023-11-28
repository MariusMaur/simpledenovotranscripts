#!/bin/bash

# Variables for resources; default to previous values if not specified
JOB_NAME=${JOB_NAME:-trinity_phase1}
TIME=${TIME:-72:00:00}
NTASKS=${NTASKS:-1}
CPUS=${CPUS:-32}
MEM=${MEM:-128G}
PARTITION=${PARTITION:-bigmem}

#SBATCH --job-name=$JOB_NAME
#SBATCH --time=$TIME
#SBATCH --ntasks=$NTASKS
#SBATCH --cpus-per-task=$CPUS
#SBATCH --mem=$MEM
#SBATCH --partition=$PARTITION

# Trinity
SINGULARITY_CONTAINER=/cluster/projects/nn9825k/software/trinityrnaseq.v2.15.1.simg

# Variables passed from command line
ID=$1
R1_INPUT=$2 # This will now point to the Trimmomatic output
R2_INPUT=$3
LONG_READS=$4  # If provided

OUTPUT_DIR="3_trinity/${ID}/${ID}_trinity"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

TRINITY_PARAMS="--seqType fq --left $R1_INPUT --right $R2_INPUT --SS_lib_type RF --CPU 32 --max_memory 128G --full_cleanup --output $OUTPUT_DIR"

# Check if long reads are provided and append to the parameters
if [[ "$LONG_READS" != "NA" && -f "$LONG_READS" ]]; then
    echo "Running with long reads: $LONG_READS"
    TRINITY_PARAMS+=" --long_reads $LONG_READS"
    LONG_READS_DIR=$(dirname "$(realpath $LONG_READS)")
    singularity exec --bind $PWD --bind $LONG_READS_DIR -e $SINGULARITY_CONTAINER Trinity $TRINITY_PARAMS
    rm -r $OUTPUT_DIR
else
    echo "Running without long reads"
    # Here we just run Trinity with the parameters without long reads
    singularity exec --bind $PWD -e $SINGULARITY_CONTAINER Trinity $TRINITY_PARAMS
    rm -r $OUTPUT_DIR
fi