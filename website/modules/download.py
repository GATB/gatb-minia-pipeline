#!/usr/bin/env python

#Download Module
#Developed using Bio-Python


from Bio import SeqIO
import urllib2
import sys
import ast
import os


#List containing the scaffold numbers which are to be downloaded
download = ast.literal_eval(sys.argv[2])


#Naming of the list download to match with the record-id's
for i in range(0,len(download)):
	download[i]="scaffold_"+str(download[i])


#URL containing the file 
url = sys.argv[1]

#Reading the file from the url
txt = urllib2.urlopen(url).read()

#Naming the file uniquely
file_name = "temp" + ".fasta"

#print file_name


#Opening the file
f =open(file_name,"w")


f.write(txt)

#print sys.argv[2]

#Usage of Bio-Python Fasta file parser
for seq_record in SeqIO.parse(file_name, "fasta"):
	if seq_record.id in download:
		
		print seq_record.id
		print seq_record.seq
		

    
#Closing the File
f.close()

#Removing the file from server
os.remove(file_name)

