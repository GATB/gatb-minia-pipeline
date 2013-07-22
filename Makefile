all:
	make -C superscaffolder
	make -C kmergenie
	#make -C minia # will be dynamically compiled

.FORCE:

test: .FORCE
	cd test ; ../gatb -p ../reads/small_test_reads.fa
