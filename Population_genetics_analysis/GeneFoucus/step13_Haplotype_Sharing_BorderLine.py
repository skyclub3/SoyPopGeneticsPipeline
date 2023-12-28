import sys, os, string, operator, glob, gzip, math, time
from itertools import *
import numpy as np

args = sys.argv
if len(args) != 3:
    print 'Usage: [namevcf] [BordPop]'
    sys.exit()


infilename = args[1]
pop = args[2]

outfile_name = infilename.rstrip('.txt') + '.borded.txt'
outfile = open(outfile_name, 'w')

bor = []

for line in imap(lambda x:x.rstrip('\n').rstrip('\r').split('\t'), open(pop)):
    bor.append(line[0])


count = 0
for line in imap(lambda x:x.rstrip('\n').rstrip('\r').split('\t'), open(infilename)):
    if line[0].startswith('POS'):
        llen = len(line)
        print >>outfile, '\t'.join(line)
        continue
    print >>outfile, '\t'.join(line)
    if line[0] in bor:
        z_line = ['0'] * llen
        count = count + 1
        if count == 2:
            print >>outfile, '\t'.join(z_line)
            count =0
            continue
        continue

outfile.close()
            


