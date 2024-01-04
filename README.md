## SimpleDeNovoTranscripts <!-- omit in toc -->

### Table of contents <!-- omit in toc -->
- [Script overview](#script-overview)
- [Usage](#usage)
  - [Prepare environment](#prepare-environment)
  - [How to run:](#how-to-run)
  - [Input data:](#input-data)
    - [`--sra` input:](#--sra-input)
    - [`--local` input:](#--local-input)
- [Run example](#run-example)
  - [Output](#output)
- [Full help](#full-help)
- [Program versions](#program-versions)


## Script overview

The script automates a workflow of either fetching Sequence Read Archive (SRA) data or local data, and then setting up configurations to run one of two snakemake pipelines. `--sra` runs SRA prefetch before starting the pipeline [Snakefile_SRA](/snakefiles/Snakefile_SRA), while `--local` starts directly with the [Snakefile_local](/snakefiles/Snakefile_local).

**This is written specifically for the venom group at UiO and is integrated with the supercomputer Saga at Sigma2.**

## Usage

### Prepare environment

No installation required, everything you need is already prepared. Set up a screen or tmux environment then load the snakemake environment:

```bash
module load Mamba/4.14.0-0
source ${EBROOTMAMBA}/bin/activate
conda activate /cluster/projects/nn9825k/admin/mamba/marius_snakemake
```

### How to run:

- To fetch SRA data and run the snakemake pipeline:

  ```bash
  python master.py --account my_slurm_account --compleasm busco_dataset --sra my_sra_table.tsv
  ```

- To run the snakemake pipeline with local data:

  ```bash
  python master.py --account my_slurm_account --compleasm busco_dataset --local my_local_table.tsv
  ```

### Input data:


#### `--sra` input:

This table requires two columns: `species_id` and `sra_accession`. They should be tab-separated.

`sample_sra_table.tsv`:
```
species1  SRR1234567
species2  SRR1234568
species3  SRR1234569
```

In the example above:
- `species1`, `species2`, and `species3` are the identifiers for different species or samples.
- `SRR1234567`, `SRR1234568`, and `SRR1234569` are SRA accession numbers.

#### `--local` input:

This table can have three or optionally four columns: `species_id`, `r1`, `r2`, and optionally `long_reads`. They should be tab-separated.

`sample_local_data_table.tsv`:
```
species1  /path/to/species1_R1.fastq  /path/to/species1_R2.fastq  /path/to/species1_long_reads.fastq
species2  /path/to/species2_R1.fastq  /path/to/species2_R2.fastq  
species3  /path/to/species3_R1.fastq  /path/to/species3_R2.fastq  /path/to/species3_long_reads.fastq
```

In the example above:
- `species1`, `species2`, and `species3` are the identifiers for different species or samples.
- The paths `/path/to/species1_R1.fastq`, `/path/to/species1_R2.fastq`, etc., are the file paths to the paired-end reads for the corresponding sample.
- The optional `long_reads` column is for long-read sequencing data.

## Run example

```{bash}
# Input spider_table.tsv
Stegodyphus_dumicola  SRR10216514
Triconephila_clavata  SRR15356212

# Run
python master.py --sra spider_table.tsv --compleasm arachnida --account nn9825k
```

### Output

```{bash}
├── 0_slurm_logs # Slurm submission logs
│   ├── compleasm_Stegodyphus_dumicola_slurm_9743926.log
│   ├── compleasm_Trichonephila_clavata_slurm_9743250.log
│   ├── SRA_Stegodyphus_dumicola_slurm_9741736.log
│   ├── SRA_Trichonephila_clavata_slurm_9741727.log
│   ├── transdecoder_Stegodyphus_dumicola_slurm_9743907.log
│   ├── transdecoder_Trichonephila_clavata_slurm_9743913.log
│   ├── trimmomatic_Stegodyphus_dumicola_slurm_9741749.log
│   ├── trimmomatic_Trichonephila_clavata_slurm_9741748.log
│   ├── trinity_Stegodyphus_dumicola_slurm_9741918.log
│   └── trinity_Trichonephila_clavata_slurm_9741902.log
├── 1_fastqc # FastQC results
│   ├── after_trim
│   └── before_trim
├── 2_trimmomatic # Trimming results
│   ├── Stegodyphus_dumicola
│   └── Trichonephila_clavata
├── 3_trinity
│   ├── Stegodyphus_dumicola
│   └── Trichonephila_clavata
├── 4_compleasm # Compleasm results
│   ├── Stegodyphus_dumicola_compleasm
│   └── Trichonephila_clavata_compleasm
├── 5_transdecoder # Transdecoder results
│   ├── Stegodyphus_dumicola
│   └── Trichonephila_clavata
├── master.py
├── README.md
├── slurm_scripts 
│   ├── compleasm.slurm
│   ├── SRA.slurm
│   ├── transdecoder.slurm
│   ├── trimmomatic_fastq.slurm
│   └── trinity.slurm
├── snakefiles
│   ├── Snakefile_local
│   └── Snakefile_SRA
├── spiders_sra.list
├── SRA_prefetch # If --SRA
│   ├── SRR10216514
│   └── SRR15356212
├── SRA_reads # If --SRA
│   ├── Stegodyphus_dumicola
│   └── Trichonephila_clavata
└── yaml
    ├── local.yaml
    └── sra.yaml
```

## Full help

```{bash}
python master.py -h, --help
```

```{bash}
usage: master.py [-h] --account ACCOUNT --compleasm {insecta,arachnida,endopterygota,hymenoptera,sauropsida} [--trimmomatic TRIMMOMATIC] (--sra SRA | --local LOCAL)

Generate YAML files.

options:
  -h, --help            show this help message and exit
  --account ACCOUNT     Input slurm account
  --compleasm {insecta,arachnida,endopterygota,hymenoptera,sauropsida}
                        Dataset
  --trimmomatic TRIMMOMATIC
                        Options for trimmomatic. Default: "ILLUMINACLIP:/cluster/software/Trimmomatic/0.39-Java-11/adapters/TruSeq3-PE-2.fa:2:30:10 SLIDINGWINDOW:4:30 MINLEN:80"
  --sra SRA             Table with species_id and sra_accession (two columns, tab separated)
  --local LOCAL         Table with three (optionally four) columns: species_id r1 r2 [long_reads] (tab separated)
```

## Program versions
- Snakemake v7.32.4
- SRA SRA-Toolkit v3.0.3
- FastQC v0.11.9
- Trimmomatic v0.39
- Trinity v2.15.1
- Compleasm v0.2.2
- Transdecoder v5.7.0

