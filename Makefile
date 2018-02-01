all:
	@#make -C superscaffolder # using a better scaffolder now
	@#make -C minia # will be dynamically compiled
	@echo "Checking Python"
	@python -c "import scipy; print('scipy OK')"
	@python -c "import numpy; print('numpy OK')"
	@python -c "import mathstats; print('mathstats OK')"
	@python -c "import pysam; print('pysam OK')"
	@echo "There is nothing to make. All programs are provided as binaries."

.FORCE:

test: all .FORCE 
	cd test ; rm -Rf assembly* ; ../gatb --12 small_test_reads.fa.gz --nb-cores 4 #--no-error-correction
