# ASKAP Ingest Benchmarks

Performance benchmark binaries for the ASKAP (Australian Square Kilometre Array
Pathfinder) ingest pipeline, released for the purposes of vendor benchmarking
under the CSIRO RfQ process.


## Benchmarks

### tMSSink

Simulates the ASKAP ingest pipeline writing Measurement Sets (MS) with mock
visibility data. Tests the end-to-end ingest write path including data conversion,
MS creation, and parallel I/O under MPI.

### tGatherPerf

Tests raw MPI gather throughput with mock visibility data. Measures the
communication performance of the rank-aggregation step that precedes MS writing.


## Benchmark Container Image

The benchmark binaries are distributed as a Docker/OCI container image. The
image is built on top of the ASKAPsoft build environment (Ubuntu 24.04, MPICH
3.4.3) and contains all required runtime dependencies. It's stored in GitHub
registry under the following name.

```
ghcr.io/csiro/askap-ingest-benchmarks:axa-3988
```


## Benchmark Package

A package of performance tests for ASKAP ingest, which is distributed as 
a compressed file.

```
askap-ingest-benchmarks-v2.tar.bz2
```

The suit consists of the following files:

- `askap-ingest-benchmarks_axa-3988-v2.sif`: Singularity container with all the 
  required executables, libraries and check scripts. This container is made from
  the aforementioned container image.
- `setup.sh`: Common setup script for all tests.
- `test_setup.sh`: General OSU sanity test to see if MPI from host properly 
  injected into the container by checking to see if COMM world size is correct 
  (has nodes x ntasks per node).
- `test_tgather.sh`: Performance test for the general communication.
- `test_tmssink.sh`: Write performance test.
- `README.md`: This file.

Note that the scripts are also available as source code in this repository.


## Prerequisites

The following needs to be installed on the host (and corresponding modules loaded, 
if appropriate):

- `Singularity/Apptainer` container engine.
- `MPICH` or at least MPI library that is ABI compatible with MPICH.
- `SLURM`

Another requirement is a writable directory where the container and bash scripts 
are located. 
Note, it is assumed that the test will be executed from this directory.
The mock up data are written to the local directory, so it is important to run 
the tests in the appropriate location.

The scripts setup singularity-specific environment variables to inject 
host-specific MPICH library. This step is normally required to achieve adequate
performance of tgather test. The other test, tmssink, doesn't do heavy MPI 
communication and, therefore, is not as sensitive.
One may also need to define `MPICH_ROOT` environment variable to point to 
the local mpich installation or defined `SINGULARITY_MODULE` for the module
that sets up singularity runtime environment to inject MPI from the host. 

### SLURM config

The slurm configuration assumed in the acceptance tests is a partition 
called `workq` that includes all the nodes in the cluster and an account `askaprt`.
The scripts can be updated to use different partitions and accounts by changing 
`setup.sh`.


## Running the tests

Provided all prerequisites are met, the tests can be run by executing 
the appropriate bash script from the directory containing the tests,
e.g. `./test_tgather.sh` or `test_tmssink.sh`. 
At the end of the distributed job, a python script is executed from 
the container to analyse the log output and give either PASS or FAIL verdict.

These tests make use of key environment variables related to singularity 
to inject host MPI libraries in the container runtime. 
This is set in the script and should only require setting an environment variable.
Tests should be run as follows:

```bash
export MPICH_ROOT=/opt/mpich/mpich-x.y.z/
./<script_name>
```

The two tests also rely on a specific distribution of MPI ranks per node, 
specified in the tests. The two performance tests can fail such that the
python code that checks failure reports the jobs having not properly run with MPI. 
To test the basic environment is correctly working, run `test_setup.sh`,
which will run a multi-node, several ranks per node test. 


## Notes on individual tests

### test_tgather.sh

This test executes a series of MPI collective calls with the data structure 
similar to the one used in the production system. 
The script is setup to run the test with 384 ranks packing 24 ranks per node.
The number of ranks per node can be increased if necessary, only the total number
of ranks is the hard requirement (and matches our current operational use). 
The pass threshold for the average run time per cycle (across cycles, 
the data transfer is bursty, 100 such bursts are simulated) is 2.5 seconds.

**PASS**: Time to completion < 2.5 s

### test_tmssink.sh

It mimics writing patterns of the current operational setup and writes data 
in a real-world astronomy format. 
The script is setup to run the test with 288 ranks packing 18 ranks per node.
The number of ranks per node can be increased if necessary. 
The pass threshold for the average (across cycles, data writing is bursty
and 10 such bursts are simulated) is faster than 1.5 seconds.

**PASS**: Time to completion < 1.5 s


## Contact details

Contact Max Voronkov <maxim.voronkov@csiro.au> for further information
