###########################################################################################################################################
# Author: Deepak B Poduval																												  #
# Date: 10/14/22																														  #
# Location: Braun Lab, Yale University																									  #
# Filename: wf_gtex_rnaseq_aggregate.v1.slurm														  									  #
#																																		  #
# In-house RNA Seq pipeline based on GTEx v10 release. - Version 1									  									  #
# This slurm script creates different types of list to be used with helper scripts that aggregate results from RNASeQC2 and RSEM	  	  #
###########################################################################################################################################

#!/bin/bash
#SBATCH --job-name=RSEM-Aggregate
#SBATCH --out="RSEM-a-%j.out"
#SBATCH --time=00:10
#SBATCH --nodes=1 --ntasks=1 --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --mail-type=ALL

#############################################################################################
## Loop through rsem output files inside results folder for each sample and create list of 
## gene / isoforms list file and make matrix files

path=`pwd`

name=`basename $path`

cd results/

for f in */*.genes.results 
do 
	echo $f >> $name".genes.list"
done

for f in */*.isoforms.results 
do 
	echo $f >> $name".isoforms.list"
done

for f in */*.gene_tpm.gct 
do 
	echo $f >> $name".gene.tpm.gct.list"
done

for f in */*.gene_reads.gct 
do 
	echo $f >> $name".gene.reads.gct.list"
done

for f in */*.gene_fragments.gct 
do 
	echo $f >> $name".gene.fragments.gct.list"
done

for f in */*.exon_reads.gct 
do 
	echo $f >> $name".exon.reads.gct.list"
done

for f in */*.metrics.tsv 
do 
	echo $f >> $name".rnaseqc.metrices.list"
done

time apptainer exec $path/gtex_rnaseq_v10.sif /src/aggregate_rsem_results.py $name".genes.list" TPM $name 
time apptainer exec $path/gtex_rnaseq_v10.sif /src/aggregate_rsem_results.py $name".genes.list" expected_count $name 
time apptainer exec $path/gtex_rnaseq_v10.sif /src/aggregate_rsem_results.py $name".genes.list" TPM $name 
time apptainer exec $path/gtex_rnaseq_v10.sif /src/aggregate_rsem_results.py $name".genes.list" expected_count $name 
time apptainer exec $path/gtex_rnaseq_v10.sif /src/aggregate_rsem_results.py $name".genes.list" TPM $name 
time apptainer exec $path/gtex_rnaseq_v10.sif /src/aggregate_rsem_results.py $name".genes.list" expected_count $name 
time apptainer exec $path/gtex_rnaseq_v10.sif /src/aggregate_rsem_results.py $name".genes.list" TPM $name 
time apptainer exec $path/gtex_rnaseq_v10.sif /src/aggregate_rsem_results.py $name".genes.list" expected_count $name 

time apptainer exec $path/gtex_rnaseq_v10.sif /src/aggregate_rsem_results.py $name".isoforms.list" TPM $name 
time apptainer exec $path/gtex_rnaseq_v10.sif /src/aggregate_rsem_results.py $name".isoforms.list" IsoPct $name 
time apptainer exec $path/gtex_rnaseq_v10.sif /src/aggregate_rsem_results.py $name".isoforms.list" expected_count $name 

time apptainer exec $path/gtex_rnaseq_v10.sif /src/combine_GCTs.py $name".gene.tpm.gct.list" $name."_gene_tpm"
time apptainer exec $path/gtex_rnaseq_v10.sif /src/combine_GCTs.py $name".gene.reads.gct.list" $name."_gene_reads"
time apptainer exec $path/gtex_rnaseq_v10.sif /src/combine_GCTs.py $name".gene.fragments.gct.list" $name."_gene_fragments"
time apptainer exec $path/gtex_rnaseq_v10.sif /src/combine_GCTs.py $name".exon.reads.gct.list" $name."_exon_reads"

time apptainer exec $path/gtex_rnaseq_v10.sif /src/aggregate_rnaseqc_metrics.py $name".rnaseqc.metrices.list" $name"_rnaseqc" 

#--------------------------------------------------------------------------------------------
