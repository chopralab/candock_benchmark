#!/usr/bin/env bash

top_percent=(0.005 0.01 0.02 0.05 0.10 0.20 0.50 1.00)

for m in `cat $ROOT_DIR/all.lst`
do
   for i in "${top_percent[@]}"; do
       file=(${m}_pocket/$i/???.pdb)
       if [[ -s $file ]]
       then
           echo $file
           mv $file ${m}_pocket/$i/${m}_ligand.pdb
       fi
   done
done

