###########################################################################################################################################
# Author: Deepak B Poduval																												  #
# Date: 10/14/22																														  #
# Location: Braun Lab, Yale University																									  #
# Filename: wf_gtex_rnaseq.v1.sh														  												  #
#																																		  #
# In-house RNA Seq pipeline based on GTEx v10 release. - Version 1									  									  #
# This workflow is used along with the slurm script that makes joblists - wf_gtex_rnaseq_joblist.v1.slurm		  		 		  #
# No changes need to be made																											  #
# Please copy all the files from gtex_rnaseq_pipeline_v1, including references to the folder with bam files, for this script to work. 	  # 
###########################################################################################################################################

#!/bin/bash -ue

##
# The Path block to setup path of folders and files - input and outputs
############################################################################################################################################

##Path of the working folder
path=`pwd`

##Path and name for the results folder
out="$path/results"

##Crosscheck whether the folder was created
if [ ! -d "$out" ]; then
	mkdir  -p $out
fi

##Path to folder with all the references
reference="$path/references"

##Collapsed gene model references
gtf="$reference/GRCh38.gencode.collapsed.gtf"

##Takes input bam file name as a command line argument
in_file=$1

##Takes part of the name to name the outputs based on sample names.
out_name=${in_file%.b*}

#Makes specific output folder with sample name
mkdir $out/$out_name

##------------------------------------------------------------------------------------------------------------------------------------------

##
# The Log block to print the versions of the program into a log file
##
#############################################################################################################################################

log="$out/$out_name/$out_name"_program_version.log

echo "Versions log" > $log

echo -e "GTEx RNA-Seq Pipeline Version 1\n using GTEx Release V10\n" >>$log
echo -e "genome-build GRCh38.p10\tgenome-version GRCh38\tgenome-build-accession NCBI:GCA_000001405.25\n" >>$log
echo -e "Gene Model used is collapsed using custom script from GTEx\n" >>$log
 
echo "SamToFastq " >>$log 
apptainer exec $path/gtex_rnaseq_v10.sif java -jar -Xmx${SLURM_MEM_PER_NODE} /opt/picard-tools/picard.jar SamToFastq --version True >>$log

echo "STAR Version:" >>$log
apptainer exec $path/gtex_rnaseq_v10.sif STAR --version >>$log

echo "Samtools Version:" >>$log
apptainer exec $path/gtex_rnaseq_v10.sif samtools --version >>$log

echo "Mark Duplicates " >>$log
apptainer exec $path/gtex_rnaseq_v10.sif java -jar -Xmx${SLURM_MEM_PER_NODE} /opt/picard-tools/picard.jar MarkDuplicates --version True >>$log

echo "RNA-SeQC Version:  " >>$log
apptainer exec $path/gtex_rnaseq_v10.sif rnaseqc --version >>$log

echo "RSEM Version:  " >>$log
apptainer exec $path/gtex_rnaseq_v10.sif rsem-calculate-expression --version >>$log

##------------------------------------------------------------------------------------------------------------------------------------------

##
# The Workflow block creates from FASTQ to RSEM Matrix
#############################################################################################################################################

# STAR alignment
time apptainer exec $path/gtex_rnaseq_v10.sif /src/run_STAR.py $reference/star_index/ $out/$out_name/$out_name"_1.fastq.gz" $out/$out_name/$out_name"_2.fastq.gz" $out_name -t ${SLURM_CPUS_PER_TASK} -o $out/$out_name/star_out

# sync BAMs (copy QC flags and read group IDs)
time apptainer exec $path/gtex_rnaseq_v10.sif /src/run_bamsync.sh $path/$in_file $out/$out_name/star_out/$out_name".Aligned.sortedByCoord.out.bam" $out/$out_name/star_out/$out_name

# mark duplicates (Picard)
time apptainer exec $path/gtex_rnaseq_v10.sif /src/run_MarkDuplicates.py $out/$out_name/star_out/$out_name".Aligned.sortedByCoord.out.patched.bam" $out/$out_name/$out_name".Aligned.sortedByCoord.out.patched.md" -o $out/$out_name

# RNA-SeQC
time apptainer exec $path/gtex_rnaseq_v10.sif /src/run_rnaseqc.py $gtf $out/$out_name/$out_name".Aligned.sortedByCoord.out.patched.md.bam" $out_name -o $out/$out_name

# RSEM transcript quantification
time apptainer exec $path/gtex_rnaseq_v10.sif /src/run_RSEM.py $reference/rsem_reference $out/$out_name/star_out/$out_name".Aligned.toTranscriptome.out.bam" $out/$out_name/$out_name -t ${SLURM_CPUS_PER_TASK}

##------------------------------------------------------------------------------------------------------------------------------------------
