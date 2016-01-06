GATB-Pipeline
-------------

GATB-Pipeline is a de novo assembly pipeline for llumina data.
It is based on:
- Bloocoo (error correction)
- Minia (contigs assembly)
- BESST (scaffolding)


Usage
-----

Command line arguments are similar to SPAdes.

Paired reads assembly:

    ./gatb -1 read_1.fastq -2 read_2.fastq

paired-end reads given in a single file:

    ./gatb --12 interleaved_reads.fastq

Unpaired reads:

    ./gatb -s single_reads.fastq

More input options are available. Type `./gatb` for extended usage.
Type `make test` to launch a small test.


Prerequisites
-------------

- Linux 64 bits (for Minia binary)

- bwa (for BESST)

- Python >= 2.7 with the following modules (for BESST):
        * mathstats
        * scipy
        * networkx
        * pysam

  To install all of them at once, run:

        pip install --user mathstats pysam networkx scipy pyfasta


FAQ
---

Can't install scipy? (because e.g. cannot sudo) A solution is to install a python distribution that doesn't require root (it's not that hard):

- conda: http://conda.pydata.org/miniconda.html then type 'conda install scipy'

or

- activestate python: http://www.activestate.com/activepython/downloads then type 'pypm install scipy'

Support
-------

To contact an author directly: rayan.chikhi@ens-cachan.org
Community support: https://www.biostars.org/t/GATB/
