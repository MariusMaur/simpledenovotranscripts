import argparse
import os

# Function to get SRA prefetch data
def fetch_sra_data(table_path):

    # Read the table and get SRA accessions
    with open(table_path, 'r') as infile:
        for line in infile:
            if not line.strip():
                continue

            ID, SRA_ACCESSION = line.strip().split("\t")

            # Run prefetch
            os.system("cd SRA_prefetch && module load SRA-Toolkit/3.0.3-gompi-2022a && prefetch " +  SRA_ACCESSION)

# Function to create the yaml for running Snakefile_SRA
def create_sra_yaml(table_path, compleasm):
    # Convert the table path to its absolute path
    absolute_table_path = os.path.abspath(table_path)

    data = f"""samples_table: {absolute_table_path}
compleasm: {compleasm}
"""
    output_path = os.path.join("yaml", "sra.yaml")
    with open(output_path, 'w') as outfile:
        outfile.write(data)

# Function to create the yaml for running Snakefile_local
def create_local_yaml(table_path, compleasm):
    # Convert the table path to its absolute path
    absolute_table_path = os.path.abspath(table_path)

    data = f"""samples_table: {absolute_table_path}
compleasm: {compleasm}
"""
    output_path = os.path.join("yaml", "local.yaml")
    with open(output_path, 'w') as outfile:
        outfile.write(data)

# Main for argument parsing
def main():
    parser = argparse.ArgumentParser(description="Generate YAML files.")
    
    parser.add_argument('--account', required=True, help='Input slurm account')
    parser.add_argument('--compleasm', choices=['insecta', 'arachnida', 'endopterygota', 'hymenoptera', 'sauropsida'], required=True, help='Dataset')
    parser.add_argument('--trimmomatic', 
                        default="ILLUMINACLIP:/cluster/software/Trimmomatic/0.39-Java-11/adapters/TruSeq3-PE-2.fa:2:30:10 SLIDINGWINDOW:4:30 MINLEN:80", 
                        help='Options for trimmomatic. Default: "ILLUMINACLIP:/cluster/software/Trimmomatic/0.39-Java-11/adapters/TruSeq3-PE-2.fa:2:30:10 SLIDINGWINDOW:4:30 MINLEN:80"')
    
    group = parser.add_mutually_exclusive_group(required=True)
    
    group.add_argument('--sra', help='Table with species_id and sra_accession (two columns, tab separated)')
    group.add_argument('--local', help='Table with three (optionally four) columns: species_id r1 r2 [long_reads] (tab separated)')
    
    args = parser.parse_args()

    # Create the directory yaml if it doesn't exist
    if not os.path.exists("yaml"):
        os.mkdir("yaml")

    # Function to create slurm dir outputs
    if not os.path.exists("0_slurm_logs"):
        os.mkdir("0_slurm_logs")
    
    # Function to create SRA dir 
    if not os.path.exists("SRA_prefetch"):
        os.mkdir("SRA_prefetch")

    # Run Snakemake with the --sra option and the local Snakefile
    if args.sra:
        print("")
        print("---------------------")
        print("| Fetching SRA data |")
        print("---------------------")
        print("")
        fetch_sra_data(args.sra)
        print("")
        print("-----------------------------------------------")
        print("| SRA fetch done --> moving to yaml creation! |")
        print("-----------------------------------------------")
        print("")
        create_sra_yaml(args.sra, args.compleasm)
        print("")
        print("-----------------------------------------------")
        print("| sra.yaml has been created in yaml directory |")
        print("|     Snakemake pipeline started with SRA     |")
        print("-----------------------------------------------")
        print("")
        os.system(f"""snakemake --snakefile snakefiles/Snakefile_SRA --keep-going --configfile yaml/sra.yaml \
            --config trimmomatic_options='{args.trimmomatic}' \
            --cluster 'sbatch --account={args.account} \
            --output=0_slurm_logs/{{params.rule_name}}_{{wildcards.sample}}_slurm_%j.log \
            --error=0_slurm_logs/{{params.rule_name}}_{{wildcards.sample}}_slurm_%j.log \
            --time={{resources.time}} --mem={{resources.mem}}MB --cpus-per-task={{resources.cpu}}' --jobs 9999""")
    # Run Snakemake with the --local option and the local Snakefile
    elif args.local:
        create_local_yaml(args.local, args.compleasm)
        print("")
        print("-------------------------------------------------")
        print("| local.yaml has been created in yaml directory |")
        print("|  Snakemake pipeline started with local data   |")
        print("-------------------------------------------------")
        print("")
        os.system(f"""snakemake --snakefile snakefiles/Snakefile_local --configfile yaml/local.yaml \
            --config trimmomatic_options='{args.trimmomatic}' \
            --cluster 'sbatch --account={args.account} \
            --output=0_slurm_logs/{{params.rule_name}}_{{wildcards.sample}}_slurm_%j.log \
            --error=0_slurm_logs/{{params.rule_name}}_{{wildcards.sample}}_slurm_%j.log \
            --time={{resources.time}} --mem={{resources.mem}}MB --cpus-per-task={{resources.cpu}}' --jobs 9999""")




if __name__ == "__main__":
    main()
