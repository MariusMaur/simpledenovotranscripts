## SimpleDeNovoTranscripts <!-- omit in toc -->

### Table of contents <!-- omit in toc -->
- [Script overview](#script-overview)
- [Usage](#usage)
  - [Prepare environment](#prepare-environment)
  - [Example runs:](#example-runs)
  - [Input data examples](#input-data-examples)
  - [`--sra` input:](#--sra-input)
  - [`--local` input:](#--local-input)
- [Full help](#full-help)



## Script overview

The script automates a workflow of either fetching Sequence Read Archive (SRA) data or local data, and then setting up configurations to run one of two snakemake pipelines. `--sra` runs SRA prefetch before starting the pipeline [Snakefile_SRA](/snakefiles/Snakefile_SRA), while `--local` starts directly with QC and trimming of input reads.

**Disclaimer: this is written specifically for the venom group at UiO and is integrated with the HPC Saga at Sigma2.**

## Usage

### Prepare environment

No installation required, everything you need is already prepared. Before using the script, make sure the required environment is set up:

```bash
module load Mamba/4.14.0-0
source ${EBROOTMAMBA}/bin/activate
conda activate /cluster/projects/nn9825k/admin/mamba/snakemake
```

### Example runs:

- To fetch SRA data and run the snakemake pipeline:

  ```bash
  python script_name.py --account my_slurm_account --compleasm busco_dataset --sra my_sra_table.tsv
  ```

- To run the snakemake pipeline with local data:

  ```bash
  python script_name.py --account my_slurm_account --compleasm busco_dataset --local my_local_data_table.tsv
  ```

### Input data examples


### `--sra` input:

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

Usage with the script:
```bash
python script_name.py --account my_slurm_account --compleasm insecta --sra sample_sra_table.tsv
```

---

### `--local` input:

This table can have three or optionally four columns: `species_id`, `r1`, `r2`, and optionally `long_reads`. They should be tab-separated.

`sample_local_data_table.tsv`:
```
species1  /path/to/species1_R1.fastq  /path/to/species1_R2.fastq  /path/to/species1_long_reads.fastq
species2  /path/to/species2_R1.fastq  /path/to/species2_R2.fastq  
species3  /path/to/species3_R1.fastq  /path/to/species3_R2.fastq  /path/to/species3_long_reads.fastq
```

In the example above:
- `species1`, `species2`, and `species3` are the identifiers for different species or samples.
- The paths `/path/to/species1_R1.fastq`, `/path/to/species1_R2.fastq`, etc., are the file paths to the paired-end reads for the corresponding species.
- The optional `long_reads` column is for long-read sequencing data, and not every species might have this.

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



