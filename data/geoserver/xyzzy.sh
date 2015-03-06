#!/bin/sh

echo Hi.

infile=${2}
outfile=${12}

echo Input: $infile
echo Output: $outfile

cp $infile $outfile

#echo "vvvv" > $outfile
#cat $infile >> $outfile
#echo $@ >> $outfile
#echo "^^^^" >> $outfile

echo Bye.
