all:
	#make -C superscaffolder # using sspace now
	make -C kmergenie
	#make -C minia # will be dynamically compiled

.FORCE:

test: all .FORCE 
	cd test ; ../gatb -p small_test_reads.fa
