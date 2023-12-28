import sys, gzip
from itertools import *

infile = sys.argv[1] #vcf.gz


POS_list = []
for line in imap(lambda x:x.rstrip('\n').rstrip('\r').split('\t'), gzip.open(infile)):
    if line[0].startswith('#'):
        continue
    CHR = line[0]
    POS = line[1]
    POS_list.append(POS)
        

VCF = infile
Pop = "../../245_sample_list.txt"
Pop2 = "../../245_WT123.group2.txt"
Str = POS_list[0]
End = POS_list[-1]
Chr='"' + str(CHR) + '"'
Range = int(End) - int(Str)

Window = str(int(Range)/10) #50 -> 25 -> 10 -> 20
Slide = str(int(Window)/20) #4 -> 8 -> 20 -> 20

#Window = str(15000)
#Slide = str(500)
stat_head = ["File", "CHR", "STR", "EHD", "RANGE", "WIN", "SLI"]
stat = [infile, CHR, Str, End, str(Range), Window, Slide]
#print >> sys.stderr, '\t'.join(stat_head)
print >> sys.stderr, '\t'.join(stat)



#Command = ["Rscript ../../Step05_popgenome.R", VCF, Str, End, Pop, Chr, Window, Slide]
Command2 = ["Rscript ../Step05_popgenome.sub.R", VCF, Str, End, Pop2, Chr, Window, Slide]

#print ' '.join(Command)
print ' '.join(Command2)

