#!/bin/bash
set -euxo pipefail

source ./setup.sh

# number of tasks per node is a free parameter, we don't care how tightly the job is packed provided it can sustain the write speeds for the given number of ranks
export TASKS_PER_NODE=18

# we need to run the code for 288 ranks
export NUM_TASKS=288

# number of threads
export OMP_NUM_THREADS=1

# job name
export jobname=tMSSink

export SRUN_PARAMS+=" --job-name=${jobname} --ntasks ${NUM_TASKS} --tasks-per-node=${TASKS_PER_NODE} --cpus-per-task=${OMP_NUM_THREADS}"

# same log4cxx configuration for all programs/tests, there is nothing app-specific in there 
export LOGPARAM="-l /usr/local/askap-services/etc/tVerifyUVW.log_cfg"
export exe=/usr/local/askap-services/bin/tMSSink
export args=" -c /usr/local/askap-services/etc/tMSSink_full.in ${LOGPARAM}"

echo "Starting a slurm job with srun parameters: "${SRUN_PARAMS}

srun ${SRUN_PARAMS} singularity exec ${CONTAINER} ${exe} ${args} 2> err | tee output.log

status=$?

rm -rf 202*_*.ms

singularity exec ${CONTAINER} python3 /usr/local/askap-services/bin/check_tmssink.py

echo "Return code: "${status} 
