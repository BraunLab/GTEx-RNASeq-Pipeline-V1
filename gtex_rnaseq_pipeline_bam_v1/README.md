# GTEx RNA-Seq Pipeline - Bam - Version 1

## README

## TL;DR

This directory a workflow bash script, two slurm scipts. This need to be run inside the directory containing bam files, references folder and singularity container for the pipeline on farnam HPC cluster at Yale (tested and successfully completed).

## Directory

### references

The directory contains genome fasta file, indices and genes gtf file for human version GRCh38.p10 (NCBI:GCA_000001405.25). A gene model for the gtf file made using script from GTEx. Two other folders of reference indices one for STAR, mapping reads and RSEM, quantification. This gives flexibility to change references to a newer version or different version for other purposes.

## Singularity container

### gtex_rnaseq_v10.sif

This is the singularity container that inculdes all the neccessary helper scripts and programs that need to run the RNA-Seq analysis including STAR, picard, RNA-SeQC2 and RSEM. The container also has helper scripts to combine the results form individual runs.

**Note: Copy the references and singularity container from "/SAY/standard/braunlab-CC1413-MEDCCC/BraunLab_pipelines/gtex_rnaseq_pipeline_v1". Also the appropriate folder of scripts are present at the same locations. A copy of the scripts are also available at <https://github.com/BraunLab/gtex_rnaseq_pipeline_v1>.**

## Bash script

### wf_gtex_rnaseq.v1.sh

The bash script contain sequential steps required to do the RNA-Seq analysis from bam to count matrix files for individual bam files. This script takes input bam file and and runs all essential steps including creating an output log file, for genome version and program version that was run.

## Slurm scripts

Slurm is a scheduler used in farnam to schedule jobs.

### wf_gtex_rnaseq_joblist.v1.slurm

Farnam uses dSQ scheduler to serialise jobs. This slurm script will loop through the names of bam files making a joblist txt file, with eachline containing execution of workflow bash script for each bam file. It will submit the joblist to dSQ scheduler outputing the submission line to run the whole pipeline in serial.

### wf_gtex_rnaseq_aggregate.v1.slurm

This slurm script is used to make result aggregate from RSEM and RNASeQC2 runs using helper scripts.

## Instructions

Download all the contents of this directory to your destinatation folder with all the bam files to analyze.
The first step in the workflow is to run

```bash
sbatch wf_gtex_rnaseq_joblist.v1.slurm
```

This step will create a joblist file and submit it to dSQ serial job submission script with a date of run.
e.g. dsq-joblist-2022-09-14.sh
It will output a message for exact command to run.

```bash
sbatch dsq-joblist-2022-09-14.sh
```

This block of code will run the workflow on all the bam files with available resources in farnam with a "jobid". To check the progress of the run the code block below. It will give you status of the progress.

```bash
module load dSQ
dsqa -j <jobid>
```

If the run fails due to resource inavailability. If you haven't loaded dSQ module load it again and run the code block below. That should rerun all the jobs that failed.
Please refer to <https://docs.ycrc.yale.edu/clusters-at-yale/job-scheduling/dsq/> to learn more about dSQ.

```bash
#module load dSQ
dsqa -j <jobid> -f jobsfile.txt > re-run_jobs.txt 2> <jobid>_report.txt
dsq --job-file re-run_jobs.txt --time=2-00:00:00 --cpus-per-task=5 --mem=35G --mail-type=ALL
```

Please feel free to contact me for any further queries  **deepak(dot)poduval(at)yale(dot)edu**
