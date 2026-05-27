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

## Container

The benchmark binaries are distributed as a Docker/OCI container image. The
image is built on top of the ASKAPsoft build environment (Ubuntu 24.04, MPICH
3.4.3) and contains all required runtime dependencies.

```
docker pull ghcr.io/csiro-internal/askap-ingest-benchmarks:latest
```

## Running the Benchmarks

Both benchmarks are driven by a LOFAR ParameterSet (parset) configuration file
passed with `-c`. An optional logger configuration file can be supplied with `-l`.

### tMSSink

```bash
mpirun -np <N> /usr/local/askap-services/bin/tMSSink \
    -c tMSSink.in \
    -l askap.log_cfg
```

Key parset parameters:

| Parameter   | Default | Description                              |
|-------------|---------|------------------------------------------|
| `count`     | 10      | Number of cycles to simulate             |
| `syncranks` | false   | Synchronise MPI ranks between cycles     |

### tGatherPerf

```bash
mpirun -np <N> /usr/local/askap-services/bin/tGatherPerf \
    -c tGatherPerf.in \
    -l askap.log_cfg
```

Key parset parameters:

| Parameter   | Default         | Description                        |
|-------------|-----------------|------------------------------------|
| `count`     | 10              | Number of gather cycles            |
| `chunksize` | 216×36×4×78     | Payload size per rank (bytes)      |

## Licence

Copyright (c) 2010 Commonwealth Scientific and Industrial Research Organisation
(CSIRO) ABN 41 687 119 230.

This software is distributed under the GNU General Public License v3 (GPL v3).
See [LICENSE](LICENSE) for the full licence text.

### Source Code Offer

In accordance with the GPL v3, the complete corresponding machine-readable
source code for this software is available on written request:

  **Contact:** Stephen Ord (stephen.ord@csiro.au)

This offer is valid for 3 years from the date of receiving this software.

### Third-Party Dependencies

This container links against a number of third-party libraries. Full licence
details for all runtime dependencies are in [3RD-PARTY.txt](3RD-PARTY.txt).

The runtime dependency audit was derived from `ldd` on the benchmark binaries
inside this container. Notable licences:

| Component         | Licence      |
|-------------------|--------------|
| LOFAR Common/Blob | GPL v3+      |
| ZeroC Ice 3.7     | GPL v2 only  |
| CASAcore 3.6.1    | LGPL v2+     |
| ZeroMQ 4.3.5      | LGPL v3      |
| GSL 2.7.1         | GPL v3       |
| WCSlib 7.3        | GPL v3       |
| FFTW 3.3.10       | GPL v2+      |
| OpenSSL 3.0.13    | Apache 2.0   |
| Boost 1.80.0      | BSL 1.0      |
| CFITSIO 4.3.0     | Public domain|
| MPICH 3.4.3       | BSD/MIT      |
