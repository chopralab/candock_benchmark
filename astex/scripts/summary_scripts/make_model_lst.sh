#!/usr/bin/env bash

top_percent=(0.005 0.01 0.02 0.05 0.10 0.20 0.50 1.00)

for m in `cat $ROOT_DIR/all.lst`
do

    prot_name=${m}

    for i in "${top_percent[@]}"; do

        if [[ -e $prot_name/$i/model.lst ]]
        then
            continue
        fi

        if [[ ! -d $prot_name/$i/ ]]
        then
            echo "$m $i was not run!"
            continue
        fi

        if [[ ! -s $prot_name/$i/LIGAND.pdb ]]
        then
            echo "$m $i does not exist"
            continue
        fi

        echo "$m $i"
        grep CONFIGUATION $prot_name/$i/LIGAND.pdb | awk '{print $8}' > $prot_name/$i/model.lst
    done
done
