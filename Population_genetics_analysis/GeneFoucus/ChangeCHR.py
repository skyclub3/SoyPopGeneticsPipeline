#!/bin/env python

import sys
from itertools import *

infile = sys.argv[1]

for line in imap(lambda x:x.rstrip('\n').rstrip('\r').split('\t'), open(infile)):
    if line[0].startswith('#'):
        print '\t'.join(line)
        continue
    if line[0][3] == '0':
        line[0] = line[0][-1]
    else:
        line[0] = line[0][3:]
    print '\t'.join(line)
 
