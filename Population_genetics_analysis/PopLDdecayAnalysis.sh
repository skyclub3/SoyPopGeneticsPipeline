#!/bin/bash

#The command you provided is a single-line bash command that uses the PopLDdecay tool to analyze Linkage Disequilibrium (LD) decay in population-level VCF data.
PopLDdecay -InVCF $1 -SubPop $2 -MaxDist 100 -OutStat $2.100LD
