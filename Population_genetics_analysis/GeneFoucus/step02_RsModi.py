import sys
from itertools import *

infile = sys.argv[1] #SNPEFF
outfile_name = infile.rstrip('.vcf') + '.reModi.txt'
outfile = open(outfile_name, 'w')

for line in imap(lambda x:x.rstrip('\n').rstrip('\r').split('\t'), open(infile)):
    if line[0].startswith('#'):
        print >>outfile, '\t'.join(line)
        continue
    if len(line) == 1 : continue
    if line[2] == ".":
        line[2] = line[0] + '-' + line[1]
        print >>outfile, '\t'.join(line)
    else:
        print >>outfile, '\t'.join(line)
else:
    outfile.close()
  
