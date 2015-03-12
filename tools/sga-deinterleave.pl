#! /usr/bin/perl
# written by J. Simpson
# from https://github.com/jts/sga/blob/master/src/bin/sga-deinterleave.pl
#
# sga-deinterleave.pl READS OUT1 OUT2
#
# Split the READS fasta/q file into two files, one for each half of a read pair
#
# modified by R. Chikhi to loosen header check
use strict;
my $inFile = $ARGV[0];
my $out1File = $ARGV[1];
my $out2File = $ARGV[2];

die("No input file given") if($inFile eq "");
die("No output file(s) given") if($out1File eq "" || $out2File eq "");

open(OUT1, ">$out1File");
open(OUT2, ">$out2File");
open(IN, ($inFile =~ /\.gz$/)? "gzip -dc $inFile |" : $inFile) || die;

my $last_header = "";

while(my $line = <IN>)
{
    chomp $line;
    my ($header) = $line; #split(' ', $line);

    my $record = "";
    if($header =~ /^>/)
    {
        # parse fasta, assume 1 line per sequence
        $record = $header . "\n" . <IN>;
    }
    elsif($header =~ /^@/)
    {
        # parse fastq
        $record = $header . "\n";
        $record .= <IN>;
        $record .= <IN>;
        $record .= <IN>;
    }
    else
    {
        next;
    }
    
    # emit record
    if(isFirstRead($header))
    {
        print OUT1 $record;
        die("Found two consecutive /1 read headers, exiting; (last header: $header)") if ($last_header eq "first");
        $last_header = "first";
    }
    else
    {
        print OUT2 $record;
        die("Found two consecutive /2 read headers, exiting; (last header: $header)") if ($last_header eq "second");
        $last_header = "second";
    }
}

close(OUT1);
close(OUT2);
close(IN);

sub isFirstRead
{
    my ($header) = @_;
    return 1 if($header =~ /[^\w]A([^\w]|$)|[^\w]1([^\w]|$)/);
    return 0 if($header =~ /[^\w]B([^\w]|$)|[^\w]2([^\w]|$)/);
    die("Cannot parse record $header");
}
