import sys
from itertools import *

infile = sys.argv[1] #SNPEFF
outfile_name = infile.rstrip('.txt') + '.vcf'
outfile = open(outfile_name, 'w')

for line in imap(lambda x:x.rstrip('\n').rstrip('\r').split('\t'), open(infile)):
    if line[0].startswith('##'):
        print >>outfile, '\t'.join(line)
        continue
    if line[0].startswith('#'):
        sample_head = line[9:]
        info_head = line[:5] + ["QUAL", "FILTER", "INFO", "FORMAT"]
        new_head = info_head + sample_head
        print >>outfile, '\t'.join(new_head)
        continue
    sample_data = line[9:]
    info_data = line[:5] + [".", ".", ".", "GT"]
    new_data = info_data + sample_data
    print >>outfile, '\t'.join(new_data)
else:
    outfile.close()
  
