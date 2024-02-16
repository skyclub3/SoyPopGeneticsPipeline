#~!/bin/env bash

if [ $# -eq 1 ]
then
    echo "START" $0
else
    echo ""
    echo "Usage : sh $0  [Type START]"
    echo ""
    exit
fi

############################################################################################
#(1) step00 : Preperation

echo "Preparation..."

for i in $(ls src/*gz)
do
   echo -e "Decompressing $i ..."
   tar xvfz $i -C src 
done

echo "Done"

###########################################################################################
