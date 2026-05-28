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
#
# Main image is askap-services.
ARG MAIN_IMAGE="ghcr.io/csiro-internal/askap-services:main"
FROM ${MAIN_IMAGE} AS main_image


# The target image is Pawsey's Lustre-aware MPICH image.
FROM quay.io/pawsey/mpich-lustre-base:3.4.3_ubuntu24.04_lustrerelease_python3.11

LABEL org.opencontainers.image.title="ASKAP Ingest Benchmarks"
LABEL org.opencontainers.image.description="tMSSink and tGatherPerf performance benchmark binaries for ASKAP ingest"
LABEL org.opencontainers.image.vendor="CSIRO"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"
LABEL org.opencontainers.image.source="https://github.com/csiro-internal/askap-ingest-benchmarks"

# Some contents from the main image are copied across to the target image.
# These are the main binaries.
COPY --from=main_image /usr/local/askap-services/bin/tMSSink /usr/local/askap-services/bin/tMSSink
COPY --from=main_image /usr/local/askap-services/bin/check_tmssink.py /usr/local/askap-services/bin/check_tmssink.py
COPY --from=main_image /usr/local/askap-services/bin/tGatherPerf /usr/local/askap-services/bin/tGatherPerf
COPY --from=main_image /usr/local/askap-services/bin/check_tgather.py /usr/local/askap-services/bin/check_tgather.py

# The followings are the supporting files and libraries.
COPY --from=main_image /usr/local/askap-services/etc/ /usr/local/askap-services/etc/
COPY --from=main_image /usr/local/askap-services/lib/ /usr/local/askap-services/lib/
COPY --from=main_image /usr/bin/spack/ /usr/bin/spack/
COPY --from=main_image /bin/spack/ /bin/spack/
# Copying to temporary location to avoid overwriting existing files in the target image.
COPY --from=main_image /usr/local/lib/ /root/tmp/usr/local/lib/
COPY --from=main_image /lib/x86_64-linux-gnu/ /root/tmp/lib/x86_64-linux-gnu/

RUN echo "Copying from temporary location" \
    && cp -r --update=none /root/tmp/usr/local/lib/* /usr/local/lib/ \
    && cp -r --update=none /root/tmp/lib/x86_64-linux-gnu/* /lib/x86_64-linux-gnu/ \
    && echo "Cleaning up" \
    && rm -rf /root/tmp \
    && ldconfig

# Measures data
COPY --from=main_image /usr/local/share/casacore/ /usr/local/share/casacore/

# Install licence and notice files alongside the binaries
COPY NOTICE         /usr/local/askap-services/NOTICES/NOTICE
COPY LICENSE        /usr/local/askap-services/NOTICES/LICENSE
COPY 3RD-PARTY.txt  /usr/local/askap-services/NOTICES/3RD-PARTY.txt
COPY README.md      /usr/local/askap-services/NOTICES/README.md

# Switch to normal user
ARG USER_NAME=askap-user 
ARG USER_UID=1001
ARG USER_GID=${USER_UID} 
RUN groupadd --gid ${USER_GID} ${USER_NAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USER_NAME} \
    && echo ${USER_NAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER_NAME} \
    && chmod 0440 /etc/sudoers.d/${USER_NAME} 
USER ${USER_NAME} 
ARG HOME=/home/askap-user/
WORKDIR ${HOME}
CMD ["/bin/bash"] 
