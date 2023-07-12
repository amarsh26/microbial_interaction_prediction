FROM kbase/sdkpython:3.8.0
MAINTAINER KBase Developer
# -----------------------------------------
# In this section, you can install any system dependencies required
# to run your App.  For instance, you could place an apt-get update or
# install line here, a git checkout to download code, or run any other
# installation scripts.

RUN apt-get update && apt-get -y upgrade \
  && apt-get install -y --no-install-recommends \
    git \
    wget \
    g++ \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*



RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN conda create -n py39 python=3.9 \
    && source activate py39 \
    && conda install nose jinja2 \
    && pip3 install jsonrpcbase numpy pandas biopython \
    && pip3 install coverage

WORKDIR /tmp

RUN apt-get update && \
    apt-get -y install apt-transport-https gnupg

RUN wget http://dl.secondarymetabolites.org/antismash-stretch.list -O /etc/apt/sources.list.d/antismash.list && \
    wget -q -O- http://dl.secondarymetabolites.org/antismash.asc | apt-key add -

RUN apt-get update && \
    apt-get -y install hmmer2 hmmer diamond-aligner fasttree prodigal ncbi-blast+ muscle glimmerhmm

RUN wget https://dl.secondarymetabolites.org/releases/7.0.0/antismash-7.0.0.tar.gz  \
      && tar -zxf antismash-7.0.0.tar.gz

RUN source activate py39 && pip install ./antismash-7.0.0
RUN source activate py39 && download-antismash-databases && antismash --check-prereqs



WORKDIR /

COPY install_dependencies.sh /tmp
RUN bash /tmp/install_dependencies.sh

#ENV PATH1=$PATH
# Set up mambaforge
#RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh
#RUN bash Mambaforge-Linux-x86_64.sh -b -p "/mambaforge"
#ENV PATH="/mambaforge/bin:$PATH"



#WORKDIR /

#RUN echo '12' >/dev/null && mkdir deps && cd deps && \
#        git clone --branch main https://github.com/dileep-kishore/antibiotic-prediction.git


# Set up RGI5
#RUN mamba env create -f deps/antibiotic-prediction/env_rgi5.yml

# Set up natural product
#RUN mamba env create -f deps/antibiotic-prediction/env_natural_product.yml


# -----------------------------------------

#ENV PATH=$PATH1


COPY ./ /kb/module
RUN mkdir -p /kb/module/work
RUN chmod -R a+rw /kb/module

WORKDIR /kb/module

RUN make all

ENTRYPOINT [ "./scripts/entrypoint.sh" ]

CMD [ ]
