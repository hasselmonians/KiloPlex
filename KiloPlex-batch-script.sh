#!/bin/bash -l

#$ -l gpus=0.5
#$ -l gpu_c=3.5
#$ -o log
#$ -e err
#$ -P PROJECT_NAME
#$ -N BATCH_NAME
#$ -l h_rt=24:00:00
#$ -t 1-NUM_FILES

module load matlab/2018a
module load cuda/9.0

matlab -nodisplay -singleCompThread -r "batchFunction(ARGUMENT); exit;"
