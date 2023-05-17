FROM ubuntu
# us.gcr.io/broad-gatk/gatk:4.2.5.0
# FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:2.2.10
# modifying from https://github.com/DataBiosphere/terra-docker/blob/master/terra-jupyter-aou/Dockerfile

USER root

# need to apt-get everything for python since we can only copy pip installed packages
RUN apt-get update && apt-get install -yq --no-install-recommends \
  jq \
  g++ \
  less \
  liblz4-dev \
  libmagick++-dev \
  iproute2 \
  # Nirvana/.NET Core dependencies \
  ca-certificates \
  libc6 \
  libgcc1 \
  libgssapi-krb5-2 \
  libicu60 \
  liblttng-ust0 \
  libssl1.0.0 \
  libstdc++6 \
  zlib1g \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV PIP_USER=false

# pandas-profiling 3.1.0 causes conflicts with pyplot
# pandas-profiling 3.2.0 is incompatible with markupsafe 2.0.1
# 3.0.0 (lower is untested) avoids both of these issues.
# RUN pip3 install --upgrade \
#   "pandas_profiling<=3.0.0" \
#   "markupsafe==2.0.1"

# RUN pip3 install \
#       nbstripout \
#       papermill \
#       dsub \
#       "git+https://github.com/all-of-us/workbench-snippets.git#egg=terra_widgets&subdirectory=py"

# # Install bcftools
# RUN mkdir -p /tmp/bcftools && \
#     cd /tmp/bcftools && \
#     curl -L -o bcftools.tar.bz2 https://github.com/samtools/bcftools/releases/download/1.12/bcftools-1.12.tar.bz2 && \
#     bzip2 -d bcftools.tar.bz2 && \
#     tar xvf bcftools.tar && \
#     cd bcftools-1.12 && \
#     make && \
#     make install && \
#     cd $HOME && \
#     rm -rf /tmp/bcftools && \

RUN git clone https://github.com/lh3/bwa.git
    cd bwa; make
    cd ../

    
