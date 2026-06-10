#!/bin/bash

source ./setup.sh

# we need to be able to run the code on 384 ranks
export NUM_TASKS=384

# number of tasks per node matches our current system / operational use
export TASKS_PER_NODE=24

# number of threads
export OMP_NUM_THREADS=1

# job name
jobname=tGather

export SRUN_PARAMS+=" --job-name=${jobname} --ntasks ${NUM_TASKS} --tasks-per-node=${TASKS_PER_NODE} --cpus-per-task=${OMP_NUM_THREADS}"

# same log4cxx configuration for all programs/tests, there is nothing app-specific in there 
export LOGPARAM="-l /usr/local/askap-services/etc/tVerifyUVW.log_cfg"
export exe=/usr/local/askap-services/bin/tGatherPerf
export args="-c /usr/local/askap-services/etc/tGatherPerf.in ${LOGPARAM}"

echo "Starting a slurm job with srun parameters: "${SRUN_PARAMS}

# running MPI-enabled code
srun ${SRUN_PARAMS} singularity exec ${CONTAINER} ${exe} ${args} 2> err | tee output.log 

status=$?

#python script checking validity of results
singularity exec ${CONTAINER} python3 /usr/local/askap-services/bin/check_tgather.py

echo "Return code: "${status} 
