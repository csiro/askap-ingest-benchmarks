#!/bin/bash
set -euxo pipefail

# if there is a module that sets up an MPI compatible singularity environment
if [[ -z $MPICH_ROOT  && -z $SINGULARITY_MODULE ]]; then
	echo "Must define either MPICH_ROOT or SINGULARITY_MODULE"
	exit 1
fi

if [ ! -z $SINGULARITY_MODULE ]; then
	module load ${SINGULARITY_MODULE}
elif [ ! -z $MPICH_ROOT ]; then
	export SINGULARITY_BINDPATH="${MPICH_ROOT}"
	export SINGULARITYENV_LD_LIBRARY_PATH="${MPICH_ROOT}/lib:${LD_LIBRARY_PATH}"
	export SINGULARITYENV_LD_PRELOAD="${MPICH_ROOT}/lib/libmpi.so"
	# update with the singularity cache directory
	export SINGULARITY_CACHEDIR="./.singularity" 
fi

export IMAGE_FILE="askap-ingest-benchmarks_axa-3988-v2.sif"

export WORK_DIR=`pwd`
export CONTAINER="${WORK_DIR}/${IMAGE_FILE}"

export SLURM_EXIT_ERROR=100
export SLURM_EXIT_IMMEDIATE=101


# note, on our current ingest cluster things don't work correctly without --mpi=pmi2 but otherwise it is not needed (and we didn't have it with the old o/s)
# symptoms of incorrect operation - all ranks are reported as 0, collective gather is too fast (probably not transferring the data correctly)
export ADDOPT="--mpi=pmi2"
#export ADDOPT=""

# slurm args
export account=pawsey0001
export partition=work
export timeleft="1:00:00"

export SRUN_PARAMS="--export=all -I -X --kill-on-bad-exit=1 --account=${account} --partition=${partition} --time=${timeleft} -vvv"
