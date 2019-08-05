#!/usr/bin/env bash

top_percent=(0.005 0.01 0.02 0.05 0.10 0.20 0.50 1.00)

if [[ ! -z $PBS_ENVIRONMENT ]]
then
    ncpu=${PBS_NUM_PPN}
fi

export module_to_run=cacrystal_rmsd

for m in `cat $ROOT_DIR/all.lst`
do

    prot_name=${m}

    for i in "${top_percent[@]}"; do

        if [[ -e $prot_name/$i/rmsds.lst ]]
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
            echo "$m $i does not exist!"
            continue
        fi

        original_file=$ROOT_DIR/structures/$m/prepared_ligands.pdb

        if [[ -s $ROOT_DIR/structures/$m/prepared_ligands_fixed.pdb ]]
        then
            original_file=$ROOT_DIR/structures/$m/prepared_ligands_fixed.pdb
        fi

        echo "$m $i"
        $MCANDOCK_LOCATION/cacrystal_rmsd.sh $original_file $prot_name/$i/${m}_ligand.pdb $ncpu > $prot_name/$i/rmsds.lst
        sed -i '1d;$d' $prot_name/$i/rmsds.lst
    done
done
