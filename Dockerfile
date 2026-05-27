# ASKAP Ingest Benchmark Container
#
# Adds licence and notice files to the askap-services image.
# The benchmark binaries (tMSSink, tGatherPerf) are installed at:
#   /usr/local/askap-services/bin/
#
# Build:
#   docker build -t askap-ingest-benchmarks .
#
# Run (see README.md for usage):
#   docker run --rm askap-ingest-benchmarks tMSSink --help

ARG BASE_IMAGE="ghcr.io/csiro-internal/askap-services:AXA-3986-tests-for-ingest-rfq"
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="ASKAP Ingest Benchmarks"
LABEL org.opencontainers.image.description="tMSSink and tGatherPerf performance benchmark binaries for ASKAP ingest"
LABEL org.opencontainers.image.vendor="CSIRO"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"
LABEL org.opencontainers.image.source="https://github.com/csiro-internal/askap-ingest-benchmarks"

# Install licence and notice files alongside the binaries
COPY NOTICE         /usr/local/askap-services/NOTICES/NOTICE
COPY LICENSE        /usr/local/askap-services/NOTICES/LICENSE
COPY 3RD-PARTY.txt  /usr/local/askap-services/NOTICES/3RD-PARTY.txt
COPY README.md      /usr/local/askap-services/NOTICES/README.md
