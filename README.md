2023 update
-----------

You may still use GATB-minia-pipeline in 2023 to assemble short reads. When doing so, I recommend a few tweaks: skip installation of bwa/BESST, and use options `--no-scaffolding --no-error-correction`. You will still get a fine an efficient multi-k assembly, without paired-end information that doesn't bring much contiguity gain in paired-end short reads anyway. -Rayan

GATB-Minia-Pipeline
-------------

GATB-Minia-Pipeline is a de novo assembly pipeline for Illumina data. It can assemble genomes and metagenomes.

It is multi-k, to aim for high contiguity. Similar software: MEGAHIT, metaSPAdes.

The pipeline consists of:
- Bloocoo (error correction)
- Minia 3 (contigs assembly) based on the BCALM2 (unitigs assembly) tool
- BESST (scaffolding)

Prerequisites
-------------

- Linux 64 bits (for Minia binary)

- bwa (for BESST)

- Python >= 2.7 and < 3 for BESST:

    * BESST 

BESST does not have a solid Python 3 support, hence only Pytohn 2 is supported.

See next section for a quick way to install them.
Note: these Python modules are only needed for BESST. 
You can skip them if you do not plan on performing scaffolding.
 
Installation
------------

    python2 -m pip install --user BESST

    git clone --recursive https://github.com/GATB/gatb-minia-pipeline

    cd gatb-minia-pipeline ; make test

Usage
-----

Command line arguments are similar to SPAdes.

Paired reads assembly:

    ./gatb -1 read_1.fastq -2 read_2.fastq

paired-end reads given in a single file:

    ./gatb --12 interleaved_reads.fastq

Unpaired reads:

    ./gatb -s single_reads.fastq

The final assembly is in:

    assembly.fasta

All other files are intermediary.

More input options are available. Type `./gatb` for extended usage.

Since the pipeline is multi-k, it is unnecessary to specify a kmer size.

Install FAQ
---

Don't copy the `./gatb` script to a bin folder it is meant to stay in that directory.

If you have trouble installing BESST, just give up and run `./gatb` nevertheless. You can just skip the scaffolding step and the pipeline will still generate contigs.

If you want to persist compiling, read on.

Can't install BESST ? Try [Conda (with Python 2)](https://repo.anaconda.com/miniconda/Miniconda2-latest-Linux-x86_64.sh) or [Activestate](http://www.activestate.com/activepython/downloads)

Support
-------

To contact an author directly: rayan.chikhi@ens-cachan.org
