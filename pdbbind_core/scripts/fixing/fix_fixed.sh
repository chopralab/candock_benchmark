#!/usr/bin/env bash

top_percent=(0.005 0.01 0.02 0.05 0.10 0.20 0.50 1.00)

ncpu=1

for m in `cat $ROOT_DIR/core.lst`
do
   for i in "${top_percent[@]}"; do
       if [[ -d ${m}_pocket_fixed/$i ]]
       then
           mv ${m}_pocket_fixed/$i/*.pdb ${m}_pocket/$i/
           rmdir ${m}_pocket_fixed/$i/
       fi 
   done;
done

