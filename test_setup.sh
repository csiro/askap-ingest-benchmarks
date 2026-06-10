#!/bin/bash

source ./setup.sh

# we need to be able to run the code on 384 ranks
export NUM_TASKS=384

# number of tasks per node matches our current system / operational use
export TASKS_PER_NODE=24

# number of threads
export OMP_NUM_THREADS=1

# job name
jobname=osu

# srun args
export SRUN_PARAMS+=" --job-name=${jobname} --ntasks ${NUM_TASKS} --tasks-per-node=${TASKS_PER_NODE} --cpus-per-task=${OMP_NUM_THREADS} "

# run simple test
echo "Running simple osu test with ${SRUN_PARAMS}"
echo "Singularity environment variables"
env | grep SINGULARITY
echo "MPICH environment variables"
env | grep MPICH

#srun ${SRUN_PARAMS} singularity exec ${CONTAINER} /usr/local/libexec/osu-micro-benchmarks/mpi/startup/osu_hello
