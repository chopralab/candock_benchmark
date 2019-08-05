#!/usr/bin/env bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=4:00:00
#PBS -l naccesspolicy=singleuser
#PBS -v ROOT_DIR,MCANDOCK_LOCATION,CANDOCK_top_percent
#PBS -d .

export module_to_run=dock_fragments

for j in `cat $ROOT_DIR/all.lst`
do

    protein_name=${j}

    export CANDOCK_verbose=1
    export CANDOCK_benchmark=1

    export CANDOCK_receptor=$ROOT_DIR/structures/$j/${protein_name}.pdb

    if [[ -s $ROOT_DIR/structures/$j/${protein_name}_fixed.pdb ]]
    then
        export CANDOCK_receptor=$ROOT_DIR/structures/$j/${protein_name}_fixed.pdb
    fi
 
    export CANDOCK_centroid=$ROOT_DIR/structures/$j/site.cen
    export CANDOCK_prep=$ROOT_DIR/structures/$j/prepared_ligands.pdb
    export CANDOCK_seeds=$ROOT_DIR/structures/$j/seeds.txt
    export CANDOCK_seeds_pdb=$ROOT_DIR/structures/$j/seeds.pdb
    export CANDOCK_top_seeds_dir=$ROOT_DIR/seeds_database/$protein_name
    export CANDOCK_docked_dir=$CANDOCK_top_percent
	export CANDOCK_gaff_heme=$ROOT_DIR/ic6.dat

    if [[ -d $CANDOCK_top_seeds_dir ]]
    then
        continue
    fi

    mkdir -p $CANDOCK_top_seeds_dir
    echo "$protein_name"

    $MCANDOCK_LOCATION/dock_fragments.sh > $CANDOCK_top_seeds_dir/output.log 2> $CANDOCK_top_seeds_dir/errors.log
done
