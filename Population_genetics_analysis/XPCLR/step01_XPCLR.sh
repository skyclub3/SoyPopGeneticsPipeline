#!bin/usr/env bash
#===============================================================================================================================================================================
INPUT=vcf.gz
th=5
#===============================================================================================================================================================================
SET=$(seq 1 20)
POP1=`cat POP1.txt`
POP2=`cat POP2.txt`
for i in $SET
 do j_count=`jobs -l|wc|awk '{print $1}'`
  if [[ $j_count -ge $th ]];then
    until [[ $j_count -lt $th ]]
      do j_count=`jobs -l|wc|awk '{print $1}'`
      sleep 0.1
      done
  fi
###########################################
# threads 에 명령 넘기는 부분.

OUT=XPCLR/POP1_POP2/POP1.POP2.chr$i
xpclr --format vcf --input ${INPUT} -Sa "$POP1" -Sb "$POP2"  --phased  --chr $i  -O ${OUT} --size 50000 --step 25000  &
done
###########################################

lastPIDs=`jobs -l|awk '{print $2}'`
wait $lastPIDs
echo "";echo "work complet."
