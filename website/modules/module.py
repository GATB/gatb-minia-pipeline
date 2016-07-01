#!/usr/bin/env python
# Module 1
#GATB
# This module will compute the GC% , Number of contigs , size of each contig
# Developed using Knutt-Morris-Pratt String Matching Algorithm




import json

file_genomic = open("assembly.fasta","r");

#Reading the File
file_read = file_genomic.read();


#Algorithmic Implementation for String matching 
#This function will be used for computing GC% 
# Time complexity is O(m+n) which is pretty efficient for large computation 

def KnuthMorrisPratt(text, pattern):

	'''Yields all starting positions of copies of the pattern in the text.
Calling conventions are similar to string.find, but its arguments can be
lists or iterators, not just strings, it returns all matches, not just
the first one, and it does not need the whole text in memory at once.
Whenever it yields, it will have read the text exactly up to and including
the match that caused the yield.'''

	# allow indexing into pattern and protect against change during yield
	pattern = list(pattern)

	# build table of shift amounts
	shifts = [1] * (len(pattern) + 1)
	shift = 1
	for pos in range(len(pattern)):
		while shift <= pos and pattern[pos] != pattern[pos-shift]:
			shift += shifts[pos-shift]
		shifts[pos+1] = shift

	# do the actual search
	startPos = 0
	matchLen = 0
	for c in text:
		while matchLen == len(pattern) or \
			  matchLen >= 0 and pattern[matchLen] != c:
			startPos += shifts[matchLen]
			matchLen -= shifts[matchLen]
		matchLen += 1
		if matchLen == len(pattern):
			yield startPos



#yield is like return over here, however it is returning an object which has to be iterated through to get all the result


#Calling the KMP function for GC computation
answer_a = KnuthMorrisPratt(file_read,"A");
answer_t = KnuthMorrisPratt(file_read,"T");
answer_g = KnuthMorrisPratt(file_read,"G");
answer_c = KnuthMorrisPratt(file_read,"C");

#Initializing the count variables
count_a = 0;
count_t = 0;
count_g = 0;
count_c = 0;

#Counting the variables
for i in answer_a:
	count_a = count_a + 1

for i in answer_t:
	count_t = count_t + 1

for i in answer_g:
	count_g = count_g + 1

for i in answer_c:
	count_c = count_c + 1


#GC %

#Total Length of contigs 
count_total = count_a + count_t + count_g + count_c


#Total Length of G and C
count_gc = count_g + count_c


gc_percentage = (float(count_gc) * 100) / float(count_total)


#print count_gc
#print count_total

#print "GC percentage"
#print  gc_percentage



#Finding the number of contigs

count_contig = 0;


#Calling the KMP function for finding the number of contigs which will return an object
no_of_contig = KnuthMorrisPratt(file_read,"scaffold")


#list for storing all the contig position
contig_pos = [];
contig_size = [];


#This will store the individual sizes of each contig except the last contig
for i in no_of_contig:
	count_contig = count_contig + 1
	contig_pos.append(i)
	if count_contig > 1:
		if count_contig <= 10:
			temp_size = contig_pos[count_contig - 1] - contig_pos[count_contig - 2] - 12
			contig_size.append(temp_size)
		elif count_contig >10 and count_contig<=100:
			temp_size = contig_pos[count_contig - 1] - contig_pos[count_contig - 2] - 13
			contig_size.append(temp_size)
		elif count_contig >100 and count_contig<=1000:
			temp_size = contig_pos[count_contig - 1] - contig_pos[count_contig - 2] - 14
			contig_size.append(temp_size)
		elif count_contig>1000 and count_contig<=10000:
			temp_size = contig_pos[count_contig - 1] - contig_pos[count_contig - 2] - 15
			contig_size.append(temp_size)
		




#This snippet will compute the contig size of the last contig
pos_last = contig_pos[count_contig - 1]
length = len(file_read)

count_last = 0

for i in range(pos_last,length):
	count_last = count_last + 1


if count_contig<10:
	contig_size.append(count_last - 12)
elif count_contig>=10 and count_contig<100:
	contig_size.append(count_last - 13)
elif count_contig>=100 and count_contig<1000:
	contig_size.append(count_last - 14)
elif count_contig>=1000 and count_contig<10000:
	contig_size.append(count_last - 15)
elif count_contig>=10000 and count_contig<100000:
	contig_size.append(count_last - 16)


	  
		

	




	 

#Printing the number of contigs
#print "Total Number of Contigs: "
#print count_contig

#print "Printing the individual contig sizes...."


#for i in range(0,len(contig_size)):
	#print "Contig " + str(i+1) + ": " + str(contig_size[i])
	



#computation of L50, N50 characteristics 
# What is N50?
#N50 defines assembly quality
#the N50 length is defined as the shortest sequence length at 50% of the genome. It can be thought of as the point of half of the mass of the distribution;

#Algorithm used
#Sort the list in descending order
#Start summing up until and stop at >=50% of total length
#The smallest contig in this list is the N50

#Greater the N50 better is the assembly

#print contig_size

#Initializing the dictionary
final_content = {}
final_content["sizes"]=[]
for i in range(0,len(contig_size)):
	final_content["sizes"].append(contig_size[i])


# count_total is total sum of the size of the contigs


count_50 = 0.5 * count_total

temp_count = 0
temp_list = []

n50 = 0
contig_size.sort(reverse=True);

for i in range(0,len(contig_size)):
	temp_count = temp_count + contig_size[i]
	if temp_count >= count_50:
		n50 = contig_size[i]
		break

#print "Total Size: " +str(count_total)
#print "N50: " + str(n50)


#End of N50 computation


#L50 computation

l50 = i+1
#print "L50: " + str(l50)

#End of L50 computation



#Conversion of the data into a JSON format to be returned to the client side for easy visualization and display to the end user




#The entire data will be clubbed together into JSON format


#Initial conversion into a dictionary 
#This dictionary will then be converted into JSON



final_content["total_size"] = count_total
final_content["GC"] = gc_percentage
final_content["N50"] = n50
final_content["L50"] = l50
final_content["contig_number"] = count_contig


#print final_content


#Conversion into final return JSON array 
print json.dumps(final_content)


#END OF MODULE
