import sys, os, string, operator, glob, gzip, math, time
from itertools import *
import numpy as np

args = sys.argv
if len(args) != 2:
    print 'Usage: [namevcf]'
    sys.exit()


infilename = args[1]
outfilename = infilename.split('/')[-1].rstrip('.vcf') + '.hshare.txt'
outfile = open(outfilename,'w')


arr = []

for line in imap(lambda x:x.rstrip('\n').rstrip('\r').split('\t'), open(infilename)):
    if line[0].startswith('##'): continue
    if line[0].startswith('#'):
        CHR = line[0]
        POS = line[1]
        sample = line[9:]
        new_sample = []
        for i in sample:
           ii = [i] * 2
           new_sample.extend(ii)
        new_head = [CHR, POS] + new_sample
        arr.append(new_head)
#        print '\t'.join(new_head)
        continue
    CHR = line[0]
    POS = line[1]
    data = line[9:]

    AL = []
    for gt in data:
        fr = AL.append(gt.split('|')[0])
        se = AL.append(gt.split('|')[1])

    R_count = AL.count('0')
    A_count = AL.count('1')

    new_al = []
    if R_count > A_count:
        for gt in data:
            fr = gt.split('|')[0]
            if fr == '0':
                fr = '2'
            else:
                fr = '3'
            se = gt.split('|')[1]
            if se == '0':
                se = '2'
            else:
                se = '3'
            new_al.append(fr)
            new_al.append(se)
    if R_count <= A_count:
        for gt in data:
            fr = gt.split('|')[0]
            if fr == '1':
                fr = '2'
            else:
                fr = '3'
            se = gt.split('|')[1]
            if se == '1':         
                se = '2'          
            else:
                se = '3' 
            new_al.append(fr)
            new_al.append(se)

    new_line = [CHR, POS] + new_al 
    arr.append(new_line)
#    print '\t'.join(new_line)

arr = np.array(arr)
arrt= arr.transpose()

for i in  arrt:
    i_list = list(i)
    print >>outfile, '\t'.join(i)

outfile.close()
        

