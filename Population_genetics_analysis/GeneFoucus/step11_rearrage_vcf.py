import sys, os, string, operator, glob, gzip, math, time
from itertools import *

if len(sys.argv) != 3:
    print "Usage: genotype.txt sample_list.txt"
    sys.exit()

infile1 = sys.argv[1]
infile2= sys.argv[2]
outfile_name= sys.argv[1].rstrip('.txt') + '.re.vcf'
outfile = open(outfile_name, 'w')


Sub_list = []
for line2 in imap(lambda x:x.rstrip('\n').rstrip('\r').split('\t'), open(infile2)):
    Sub_list.append(line2[0])


for line in imap(lambda x:x.rstrip('\n').rstrip('\r').split('\t'), open(infile1)):
    if line[0].startswith('##'):
        print >> outfile, '\t'.join(line)
        continue
    if line[0].startswith('#'):
        head = line
        info = line[:9]
        idx = []
        for x in Sub_list:
            idxx = head.index(x)
            idx.append(idxx)
        new_sample = []
        for y in idx:
            new_sample.append(head[y])
        new_header = info + new_sample
        print >>outfile, '\t'.join(new_header)
        continue
    data_info = line[:9]
    data_line = line
    new_data_line = []
    for t in idx:
        new_data_line.append(data_line[t])
    new_line = data_info + new_data_line
    print >>outfile, '\t'.join(new_line)
else:
    outfile.close()
