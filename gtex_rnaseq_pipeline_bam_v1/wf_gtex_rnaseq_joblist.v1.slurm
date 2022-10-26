###########################################################################################################################################
# Author: Deepak B Poduval																												  #
# Date: 10/14/22																														  #
# Location: Braun Lab, Yale University																									  #
# Filename: wf_gtex_rnaseq_joblist.v1.slurm														  										  #
#																																		  #
# In-house RNA Seq pipeline based on GTEx v10 release. - Version 1									  									  #
# This slurm script creates joblist using wf_gtex_rnaseq.v1.sh file to be submitted to dSQ job scheduler in HPC		  		 		  	  #
# Please copy all the files from gtex_rnaseq_pipeline_v1 - including references to the folder with bam files.				  			  # 
###########################################################################################################################################

#!/bin/bash
#SBATCH --job-name=dSQ-Joblist
#SBATCH --out="dSQ-%j.out"
#SBATCH --time=00:10
#SBATCH --nodes=1 --ntasks=1 --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --mail-type=ALL

#############################################################################################
## Loop through bam files and create joblist to make dSQ submission

for file in *.bam
do
	echo "bash wf_gtex_rnaseq.v1.sh $file" >> joblist.txt
done

## Load dSQ module and create serial job submission
module load dSQ
dsq --job-file joblist.txt --time=2-00:00:00 --cpus-per-task=5 --mem=35G --mail-type=ALL

##--------------------------------------------------------------------------------------------
